
# Directory containing the JSON files (you can adjust this as needed)
directory="/mnt/k/Datasets"

# Iterate over all .json files in the specified directory
for file in "$directory"/*.json; do
    # Check if the file exists
    if [[ -f "$file" ]]; then
        echo "Processing $file"
        
        # Remove the last line of the file using `sed`
        sed -i '$d' "$file"

        echo "Removed last line from $file"
    fi
done

# Iterate over all .json files in the given directory
find "$directory" -type f -name "*.json" | while read -r file; do
    echo "Processing file: $file"

    # Create a temporary file for the output
    temp_file=$(mktemp)

    # Open the file and process it line by line to replace "\r\n\n" with a comma
    # Use awk to handle carriage return + newlines efficiently
    awk 'BEGIN {RS="\r\n\n"; ORS=","} {print $0}' "$file" > "$temp_file"

    # If the temp file has content, move it back to the original file
    if [ -s "$temp_file" ]; then
        mv "$temp_file" "$file"
        echo "Updated file: $file"
    else
        rm "$temp_file"
    fi
done

python3 dict_to_json.py