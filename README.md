
# jira-logwork
Sick of manualy adjusting your daily worklog in Jira? Then this tool is for you.
It helps you quickly build your daily worklog by suggesting your recent visited Jira issues and automatically adjusts them to fill your required work schedule.

## Features
 - Add your tickets you log every day. (e.g. daily stand up)
 - Quick select which tickets to log from the suggestion list.
 - Change the worklog duration from one ticket, and it will automatically adjust the rest to fill your required daily schedule.

 ## Getting started
You need to run the initial setup wizard which will ask you to provide the essential setup configuration parameters, like JIRA Server URL, login credentials, etc.
To do so, run the following command:
```bash
jira-logwork setup
```

## Manually update configuration
You can manually update the configuration parameters by using the config command:

```bash
# Get help about the available configuration parameters
jira-logwork config
```
