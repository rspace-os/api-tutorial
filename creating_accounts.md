# Creating accounts

From RSpace 1.59.3 (API version 1.5.4) you can programmatically create new user accounts and groups.
Please note that:

* This requires a SYSADMIN role
* As of 1.59.3 / API 1.5.4 this API is provisional and subject to change. Any feedback or suggestions for feedback are welcome.

## Background

### What accounts can be created

* A sysadmin user can create users with any role, just like in the web interface

### How do I create groups?

* Firstly ensure all users exist on the system - create new users if need be.
* Then create a LabGroup, with a PI user

## Creating a user account

Send a POST request to /sysadmin/users with the details of the user to be created in the request body. A request body is shown in [createUser.json](tutorial-data/accounts/createUser.json)

```bash
curl -v  -X POST -H "content-type: application/json" -H "apiKey: <APIKEY>"\
-d "@tutorial-data/accounts/createUser.json"\
"<RSPACE_URL>/api/v1/sysadmin/users"
```

There are some restrictions on the values of data fields passed:

* All fields are mandatory unless indicated (see Swagger docs for details)
* Usernames must be >= 6 characters
* Passwords must be >= 8 characters

## Creating a group

In order to create a group, all users who are to be added to the group must already exist on the system.

Also, at least one member must have a global PI role and be assigned the role of PI in the lab.

Here is an example of a valid group post request body. All fields are required.

```json
{
  "name": "MyGroup",
  "members": [
    {
      "username": "bob123",
      "roleInGroup": "PI"
    },
    {
      "username": "labmember",
      "roleInGroup": "DEFAULT"
    }
  ]
}
```

which creates a group with 2 members, a PI and a standard member.

```bash
curl -v  -X POST -H "content-type: application/json" -H "apiKey: <APIKEY>"\
-d "@tutorial-data/accounts/createGroup.json"\
"<RSPACE_URL>/api/v1/sysadmin/groups"
```
