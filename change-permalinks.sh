for file in posts/history*; do
    # 1. Print the file being processed
    echo "--- Processing file: $file ---"

    # 2. Check if the pattern exists in the file (original state)
    if grep -E '\*\*Permalink:\*\* \"https?:\/\/[^\"]*\"' "$file"; then
        echo "Match found. Running substitution..."
        
        # 3. Run the substitution (macOS BSD sed)
        sed -i '' -E 's/\*\*Permalink:\*\* \"(https?:\/\/[^\"]*)\"/\*\*Permalink: [\1](\1)/g' "$file"
        
        # 4. Verify the replacement (new state - should show the Markdown link)
        echo "Substitution complete. New line(s):"
        grep -E '\*\*Permalink:\*\* \[https?:\/\/[^\"]*\]\(https?:\/\/[^\"]*\)' "$file"
    else
        echo "No match found. Skipping."
    fi
    echo ""
done
