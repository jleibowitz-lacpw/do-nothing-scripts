# Sentry Project Setup Steps

## Step 1: Welcome Message
Display a welcome message to the user.

## Step 2: Open Sentry Portal Instructions
- Open the Sentry portal in your browser: [Sentry Portal](https://los-angeles-county-public-works.sentry.io/)
- If logged out, log in with Active Directory (SSO).

## Step 3: Navigate to Projects Page
- Navigate to the Projects page: [Projects Page](https://los-angeles-county-public-works.sentry.io/insights/projects/)

## Step 4: Navigate to Create Project Page
- Navigate to the Create Project page: [Create Project Page](https://los-angeles-county-public-works.sentry.io/insights/projects/new/)

## Step 5: Select Project Type
- For MVC, React, or Blazor applications, select **ASP.NET Core**.
- For ASP.NET Forms, select **.NET**.

## Step 6: Set Alert Frequency
- Select **Alert me on high priority issues** for now.

## Step 7: Obtain Application Name from CAL
- Go to CAL to obtain the name of the application.
- Copy and paste it into the Project Name field.
- The name should automatically suggest all lowercase with dashes (e.g., `example-app-name`).

## Step 8: Select Team
- Select the team that the application belongs to.
- Example teams: `#data-management`, `#infrastructure-systems`, `#gis`, etc.

## Step 9: Create Project and Input Instructions URL
- Click **Create Project** in the Sentry interface.
- Paste the Instructions URL when prompted.

## Step 10: Navigate Back to Projects Page
- Navigate back to the Projects page: [Projects Page](https://los-angeles-county-public-works.sentry.io/insights/projects/)

## Step 11: Locate the Project and Click the Gear Icon
- Locate the project and click the **Gear** icon to the right of the project name.

## Step 12: Navigate to Alert Settings
- Under **General Settings**, select **Alert Settings**.

## Step 13: View Alert Rules
- Click **View Alert Rules**.

## Step 14: Edit the Existing Rule
- Edit the existing rule by selecting the 3 dots and clicking the **Edit** link.

## Step 15: Modify the WHEN Section
- Change the **WHEN** section as follows:
  1. Delete the original 2 conditions.
  2. Add the following 2 new conditions:
     - **WHEN an event is captured by Sentry and any of the following happens**
     - **A new issue is created**
     - **Number of events in an issue is more than 0 in 5 minutes**

## Step 16: Change Name and Owner Section
- Change the **Name** and **Owner** section to appropriately reflect the Alert name and Team.
- Example: Set the name to `Send notification` and the owner to the team you chose previously (e.g., `#gis`).

## Step 17: Save the Rule
- Click **Save Rule** to save your changes.

## Step 18: Navigate to Client Keys (DSN)
- Click on **Client Keys (DSN)** under the **SDK Setup** section.

## Step 19: Configure Rate Limits
- Click **Configure** in the upper right corner of the **Client Keys (DSN)** section.
- Under **Rate Limit**, enter/select **1000 events in 1 day**.

## Step 20: Copy DSN Key
- Paste the DSN key when prompted.

## Step 21: Generate Email for Developer
- Generate an email for the developer with the following content:

```
Hi [Developer Name],

The Project "[Project Name]" was created and below is the DSN key:

[DSN Key]

Sentry instructions page:
[Instructions URL]

Additional instructions:
https://github.com/la-county-dpw/PW-Library#13-pwsentry
https://docs.sentry.io/platforms
https://docs.sentry.io/platforms/dotnet/guides/aspnet/#install
https://docs.sentry.io/platforms/dotnet/guides/aspnetcore/

Wiki page:
https://lacounty.sharepoint.com/teams/DPW/cio/itdsa/devcorner/Developers%20Guide/Sentry%20Error%20Handler.aspx
```

## Step 22: Final Instructions
- Follow the instructions provided in the email and additional resources.