#!/bin/bash

# Function to normalize URL
normalize_url() {
    local url=$1
    # Remove fragment
    url=${url%%#*}
    # Remove trailing slash if present
    url=${url%/}
    # Add scheme if missing
    if [[ ! $url =~ ^https?:// ]]; then
        url="http://$url"
    fi
    echo "$url"
}

# Function to check if a link exists in the file
link_exists() {
    grep -Fxq "$1" all_links.txt
}

# Function to add a link to the file if it doesn't exist
add_link() {
    local new_link=$(normalize_url "$1")
    if ! link_exists "$new_link"; then
        echo "$new_link" >> all_links.txt
        echo "New URL discovered: $new_link"
        return 0  # Link was added
    else
        echo "URL already exists: $new_link"
        return 1  # Link already exists
    fi
}

# Function to crawl a URL
crawl_url() {
    local url=$1
    local current_level=$2
    local max_level=$3
    local domain=$(echo "$url" | sed -e 's|^[^/]*//||' -e 's|/.*$||')

    echo "Crawling: $url (Level: $current_level)"

    # Check if we've reached the maximum level
    if [ "$current_level" -gt "$max_level" ]; then
        echo "Max level reached. Stopping crawl for this branch."
        return
    fi

    # Fetch the page content using lynx
    local page_content=$(lynx -dump -hiddenlinks=listonly "$url")

    # Extract and process links
    echo "$page_content" | grep "$domain" | awk '{print $2}' | while read -r link; do
        # Normalize the link
        full_link=$(normalize_url "$link")
        
        # Check if the link belongs to the same domain
        if [[ $full_link == *$domain* ]]; then
            if add_link "$full_link"; then
                crawl_url "$full_link" $((current_level + 1)) "$max_level"
            fi
        fi
    done
}

# Function to process crawled URLs
process_urls() {
    local domain=$1
    local output_file="${domain}.txt"
    local total_words=0

    echo "Processing URLs and storing results in $output_file"

    while read -r url; do
        echo "Processing: $url"
        # Call the endpoint and append the result to the output file
        result=$(curl -s "https://r.jina.ai/${url}")
        echo "$result" >> "$output_file"
        echo "" >> "$output_file"  # Add a newline for separation
        
        # Count words in the result and add to total
        words_in_result=$(echo "$result" | wc -w | tr -d '[:space:]')
        total_words=$((total_words + words_in_result))
    done < all_links.txt

    echo "Processing complete. Results stored in $output_file"
    echo "Total unique URLs discovered: $(wc -l < all_links.txt)"
    echo "Total word count: $total_words"
}

# Main script
if [ $# -ne 2 ]; then
    echo "Usage: $0 <url> <max_level>"
    exit 1
fi

url=$(normalize_url "$1")
max_level=$2
domain=$(echo "$url" | sed -e 's|^[^/]*//||' -e 's|/.*$||')

# Create or clear the file to store all links
> all_links.txt

# Add the initial URL to the file
add_link "$url"

# Start crawling
crawl_url "$url" 0 "$max_level"

# Process the crawled URLs and output statistics
process_urls "$domain"

# Clean up
rm all_links.txt