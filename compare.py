import difflib
import re
import tkinter as tk
from tkinter import filedialog

def group_rows_by_legend(content):
    grouped_content = {}
    for line in content:
        # Extract the first character/legend
        legend = line[0] if line else ""
        
        # Add the line to the corresponding legend group
        grouped_content.setdefault(legend, []).append(line)

    return grouped_content

def flatten_nested_list(nested_list):
    return [item for sublist in nested_list for item in sublist]

def remove_html_tags(text):
    clean = re.compile('<.*?>')
    return re.sub(clean, '', text)

def compare_and_create_html():
    # Prompt the user to select the first HTML file
    file1_path = filedialog.askopenfilename(title="Select the first HTML file", filetypes=[("HTML files", "*.html")])
    
    # Prompt the user to select the second HTML file
    file2_path = filedialog.askopenfilename(title="Select the second HTML file", filetypes=[("HTML files", "*.html")])

    # Check if the user canceled the file selection
    if not file1_path or not file2_path:
        print("File selection canceled.")
        return

    # Prompt the user to select the output HTML file
    output_path = filedialog.asksaveasfilename(title="Select the output HTML file", defaultextension=".html", filetypes=[("HTML files", "*.html")])

    # Check if the user canceled the file selection
    if not output_path:
        print("Output file selection canceled.")
        return

    # Read content of the selected HTML files
    with open(file1_path, 'r', encoding='utf-8') as file1:
        file1_content = file1.readlines()

    with open(file2_path, 'r', encoding='utf-8') as file2:
        file2_content = file2.readlines()

    # Group rows by legend in both files
    grouped_file1 = group_rows_by_legend(file1_content)
    grouped_file2 = group_rows_by_legend(file2_content)

    # Flatten the nested lists
    flat_grouped_file1 = flatten_nested_list(grouped_file1.values())
    flat_grouped_file2 = flatten_nested_list(grouped_file2.values())

    # Remove HTML tags
    flat_grouped_file1_no_tags = [remove_html_tags(line) for line in flat_grouped_file1]
    flat_grouped_file2_no_tags = [remove_html_tags(line) for line in flat_grouped_file2]

    # Compare the content of the selected HTML files
    differ = difflib.HtmlDiff()
    differences = differ.make_file(flat_grouped_file1_no_tags, flat_grouped_file2_no_tags, context=True)

    # Save the result to the selected output HTML file
    with open(output_path, 'w', encoding='utf-8') as output_file:
        output_file.write(differences)

    print(f"Comparison result saved to: {output_path}")

# Create a simple Tkinter window
root = tk.Tk()
root.withdraw()  # Hide the main window

# Call the function to prompt the user and perform the comparison
compare_and_create_html()

# Uncomment the following line if you want to keep the Tkinter window open
# root.mainloop()
