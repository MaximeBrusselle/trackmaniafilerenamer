
# Trackmania files renamer

## Prerequisites

### Python script (.py)

- Ensure you have Python installed on your system.
- Have the rename.py file downloaded
- Make sure you have the necessary permissions to read from and write to the directories you are working with.

### Bash script (.sh)

- Ensure you have a Unix-like environment with Bash installed.
- Have the rename.sh file downloaded
- Make sure you have the necessary permissions to read from and write to the directories you are working with.

### Windows script (.bat and .ps1)

- Have windows lol
- Have the rename.bat and rename.ps1 file downloaded
- Make sure you have the necessary permissions to read from and write to the directories you are working with.

## Usage

### Running python script

To run the python script, open your terminal or command prompt and navigate to the directory where `rename.py` is located. Use the following command:

```shell
python rename.py <path to folder with replays> <path to output folder (doesnt have to exist)>
```

This will copy the files to the desired output folder and cleanses the name.
If no output folder is passed it will rename the files in that folder, which is done as follows:

```shell
python rename.py <path to folder with replays>
```

### Running the bash script

To run the bash script, open your terminal or command prompt and make sure that you are using a bash shell. Navigate to the directory where rename.sh is located. Use the following commands:

```shell
chmod +x rename.sh | ./rename.sh "path/to/directory" "path/to/output/directory (doesnt have to exist)"
```

This will copy the files to the desired output folder and cleanses the name.
If no output folder is passed it will rename the files in that folder, which is done as follows:

```shell
chmod +x rename.sh | ./rename.sh "path/to/directory"
```

### Running the bat script

To run the bash script, open your terminal or command prompt. Navigate to the directory where rename.bat is located. Use the following commands:

```shell
rename.bat path/to/directory path/to/output/directory (doesnt have to exist)
```

This will copy the files to the desired output folder and cleanses the name.
If no output folder is passed it will rename the files in that folder, which is done as follows:

```shell
rename.bat path/to/directory
```

## Questions or feedback

If anything is not working as desired or you have a question you can dm on discord: tailstm
