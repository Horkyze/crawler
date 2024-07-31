# Web Crawler Script

This Bash script is a simple web crawler that discovers and processes URLs within a specified domain.

It's main purpose is to create a single .txt file that can be used as a context for LLMs.

## Features

- Crawls websites up to a specified depth
- Normalizes URLs to avoid duplicates
- Stores unique URLs in a file
- Processes discovered URLs and stores results
- Counts total words in the processed results

## Usage

1. Ensure you have the required dependencies installed:
   - `lynx`: Used for fetching page content
   - `curl`: Used for processing URLs

2. Run the script with the following command:

```bash
./crawler.sh <starting_url> <max_depth>
```

Replace `<starting_url>` with the URL you want to start crawling from, and `<max_depth>` with the maximum depth of crawling.

3. The script will create two main files:
- `all_links.txt`: Contains all unique URLs discovered during crawling
- `<domain>.txt`: Contains the processed results for each URL

## Main Functions

- `normalize_url()`: Normalizes URLs to a standard format
- `add_link()`: Adds new links to the `all_links.txt` file
- `crawl_url()`: Recursively crawls URLs up to the specified depth
- `process_urls()`: Processes discovered URLs and stores results

## Limitations

- The script is designed to crawl within a single domain
- It relies on `lynx` for content extraction, which may not handle dynamic content well

## Output

The script provides the following output:
- Discovered URLs are printed to the console
- Final statistics including total unique URLs and word count are displayed
