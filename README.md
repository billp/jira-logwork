<p align="center">
	<img width="600px" src="https://raw.githubusercontent.com/billp/jira-logwork/master/jira-logwork-logo.svg">
</p>
<p align="center">
Sick of having to manually adjust your daily worklog on Jira? Then this tool is for you. <br />
It helps you quickly create your daily worklog by providing the issue ids and the desirable duration.
</p>

## Features

▫️ Create your daily work-log table using a command line wizard or an one-line command. <br />
▫️ Specify the **issue id** and optionally the duration and start time, and let the tool expand the time as needed to fill your daily log hours.


 ## Getting Started
You need to run the initial setup wizard which will ask you to provide some required initial parameters, like JIRA Server URL, login credentials, etc.

Run the following command in Terminal:
```bash
jira-logwork setup
```

## Manually Change Configuration
You can manually change the configuration parameters with the following command:

```bash
jira-logwork config [param] [[value1] [value2] ...]
```
