import os
import re
import argparse

def read_urls_from_file(file_path):
    with open(file_path, 'r') as file:
        return file.read().splitlines()

def categorize_and_save_urls(wayback_urls, output_folder):
    categorized_urls = {}

    for url in wayback_urls:
        # Extract file extension using regex
        match = re.search(r'\.([a-zA-Z0-9]+)$', url)
        if match:
            file_extension = match.group(1).lower()
            # Create a category if not exists
            if file_extension not in categorized_urls:
                categorized_urls[file_extension] = []
            categorized_urls[file_extension].append(url)

    # Create the output folder if it doesn't exist
    os.makedirs(output_folder, exist_ok=True)

    # Save URLs in separate files based on category
    for category, urls in categorized_urls.items():
        file_name = os.path.join(output_folder, f"{category}_urls.txt")
        with open(file_name, 'w') as file:
            file.write('\n'.join(urls))

if __name__ == "__main__":
    # Set up command-line argument parsing
    parser = argparse.ArgumentParser(description="Categorize Wayback Machine URLs and save them in separate files.")
    parser.add_argument('-f', '--file', required=True, help='Path to the Wayback Machine URLs text file')
    parser.add_argument('-o', '--output', required=True, help='Path to the output folder')

    # Parse command-line arguments
    args = parser.parse_args()

    # Read Wayback Machine URLs from the input file
    wayback_urls = read_urls_from_file(args.file)

    # Categorize and save URLs in separate files in the specified output folder
    categorize_and_save_urls(wayback_urls, args.output)

    print("URLs categorized and saved successfully.")
