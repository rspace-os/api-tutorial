# Getting started with OAuth for RSpace

As of RSpace 1.66, only the 'password' grant flow is supported. This requires an initial token grant using username/password credentials.

## Registering a client app as an OAuth app developer

Open your RSpace instance, and follow these steps:

1. Click on "My RSpace"
2. Click on "My Profile"
3. Click on "Show Created OAuth Apps"
4. Click on the plus sign to add a new OAuth app
5. A pop-up dialog will appear, enter the name for your app, click next
6. You will be shown a client ID and a client secret. Write down the client secret as it will not be available once the pop-up dialog is closed.

Now, anyone **on this particular RSpace instance** can acquire access/refresh tokens if they **have the client ID and the client secret**.

## Getting the access tokens

This follows standard OAuth 'password' grant flow.

To acquire a token:

```bash
export username="username"
export rspacepwd="password"
export client_id="id"
export client_secret="secret"
export RSPACE_URL=https://myrspace.com

curl -X POST -Fgrant_type="password" -Fclient_id="$client_id" \
 -Fclient_secret="$client_secret" -Fusername="$username" \
 -password="$rspacepwd" "$RSPACE_URL/oauth/token"
```

This call will return the access token, refresh tokens and a duration, in seconds, for the validity of the access token:

```bash
{
  "scope" : "all",
  "access_token" : "TuWHW0+8mUauD/y9E0HklZqrHGkA6+34",
  "refresh_token" : "rTdb7EMWXdCCdzZzMLD+EWcoXATmETll",
  "expires_in" : 3153599999
}
```

You can invoke this request as many times as you like - only 1 access token is ever valid for a specific user-appID combination, so repeated invocations of this method will invalidate any existing  access and refresh token.

## Refreshing tokens

Using example data from the above:

```bash
export refresh_token=rTdb7EMWXdCCdzZzMLD+EWcoXATmETll

curl -X POST -Fgrant_type="refresh_token" -Fclient_id="$client_id" \
 -Fclient_secret="$client_secret" -Frefresh_token="$refresh_token" "$RSPACE_URL/oauth/token"
 ```

will return a new refresh token and access token.

## Making API calls

Use your access token as follows to make API calls.

```bash
export access_token=TuWHW0+8mUauD/y9E0HklZqrHGkA6+34
## for example, list your documents
curl -H"Authorization: Bearer $access_token" "$RSPACE_URL/api/v1/documents"
```
