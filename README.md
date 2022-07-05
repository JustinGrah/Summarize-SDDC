# Summarize SDDC
A small helper tool to truncate SDDC text files into one large, sorted and comparable file for easy comparison of Servers in a Cluster

## When can i use it?
You can use it if you want to:
- Compare settings from one server to another one
- Get an overview of all settings from all servers (that are saved in text files by the SDDC)

## Is it safe to use?
Yes. The tool will not modify the original SDDC files and store the data in a seperate directory that is defined by you

## How does it work?
1. Open Powershell as a admin
2. Run the file `main.ps1`
3. Enter the root directoy of the SDDC (The directory where you can find the Get-Cluster.xml)
4. Enter the root directory on where to store the truncated files (In there you will find txt files that have the name of your nodes)
5. Wait and relax - The script now does all the work for you! You can simply wait till the script finishs

## I'm a dev and want to build something on top of it
You can! Lucky you. I've created a simple parser that will parse the text into a PowerShell object.
As long as you know on how to work with PowerShell Objects you should be good to rip it apart and use if for your own project.

## Is that a backup? / Can i use it for backup?
No.

## I have some problems...
Here might be some answers:
- What is a SDDC? See: https://docs.microsoft.com/en-us/azure-stack/hci/manage/collect-diagnostic-data
- It is showing some errors: Ensure that you have a proper SDDC and your directory is properly selected (no `\` at the end of the file path please!)