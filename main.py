import os
import sys
import re

def cleanse_filename(filename: str) -> str:
    """
    This function cleanses the filenames from color codes and multiple spaces.
    """
    base_name = filename.split('.Replay.gbx')[0]
    new_filename = base_name.replace(" ", "_")
    new_filename = re.sub(r"\$[g-zG-Z&&[^lL]]", "", new_filename)
    new_filename = re.sub(r"\$[lL]\[.*?\]", "", new_filename)
    new_filename = new_filename.replace("$l", "")
    new_filename = re.sub(r"\$[0-9a-zA-Z_]{3}", "", new_filename)
    new_filename = new_filename.replace("$$", "$")
    new_filename = re.sub(r"_{2,}", "_", new_filename)
    return f"{new_filename}.Replay.gbx"

def rename_files(directory: str, out_directory: str | None = None) -> None:
    """
    This function renames the files in the given directory or copies them to the output directory.
    """
    try:
        filenames = os.listdir(directory)
        total_files = len(filenames)
        for index, filename in enumerate(filenames):
            if total_files > 10 and index % (total_files // 10) == 0:
                percentage = (index / total_files) * 100
                print(f"Processed {percentage:.0f}% of files.")
            cleansed_filename = cleanse_filename(filename)
            original_path = os.path.join(directory, filename)
            if out_directory:
                new_path = os.path.join(out_directory, cleansed_filename)
                os.makedirs(out_directory, exist_ok=True)
                with open(original_path, 'rb') as original_file:
                    with open(new_path, 'wb') as new_file:
                        new_file.write(original_file.read())
            else:
                new_path = os.path.join(directory, cleansed_filename)
                os.rename(original_path, new_path)
        if out_directory:
            print(f"Successfully renamed all files from {directory} and saved them to {out_directory}")
        else:
            print(f"Successfully renamed all files from {directory}")
    except FileNotFoundError:
        print(f"The directory {directory} does not exist.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Usage: python main.py <directory_path> [out_directory_path]")
    else:
        directory_path = sys.argv[1]
        out_directory_path = sys.argv[2] if len(sys.argv) == 3 else None
        rename_files(directory_path, out_directory_path)
