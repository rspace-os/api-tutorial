# Getting started with OAuth for RSpace

As of RSpace 1.66, only the 'password' grant flow is supported. This requires an initial token grant using username/password credentials.

## Registering a client app

Registering a client app requires updating the RSpace server with information about the app, the ID and the secret.

There are several steps, explained in detail below. You will need access to RSpace server or someone who does. If you are in
doubt, please contact ResearchSpace support or your local RSpace administrator.

1. On RSpace server, in folder /etc/rspace (or whichever folder your `deployment.properties` file is located), open a file `oauth.properties`. This file might or might not already exist, depending on whether you are the first person to register a client app or not.
2. Edit this file to include information about your app, id, secret, token expiry time, etc.
3.  Restart RSpace for these properties to take effect.

An example oauth.properties file is shown below. If you want to get started quickly just replace 'app1' with a name for your app, - but do set your own secret in production!

```
## A comma separated list of clientIds. These are public ids and can be short, human-readable names, alphanumeric characters.
oauth.enabledClients=app1,app2
#
## Expiry time of access tokens, in seconds, in the format 'oauth.<CLIENTID>.expiryTime
## The values can be :
### -1 - essentially everlasting tokens (expiring 100 years from now)
oauth.app1.expiryTime=-1
### default - the RSpace default access token expiry time (1 hour from creation)
#oauth.app1.expiryTime=default
### A positive integer, in seconds
#oauth.app1.expiryTime=31536000

#
# plaintext secret - use this as your 'client_Secret' in API calls:
# f1zKVsaaRwudB6+0PnjXtU/JGpweYS5PfWYM50pbVXz2ANU37BNXYx+0k+CsEtLM
## SHA-256 hash of the client secret.
oauth.app1.secret=5f1e48b4aa1da45b2498c8056b7f2c90bcabbcc7c233731f6d23ecfdef3ab741
...

```
## Creating your client secret:

This can be any word or phrase, or generate a random client secret as follows:

```
openssl rand -base64 32 
```
(for key-length of 32).
Hash this secret using SHA-256 algorithm - either a command line utility or an [online generator](https://xorbin.com/tools/sha256-hash-calculator)

```
echo -n "secret key" | sha256sum 
```
(replacing 'secret key' with the key you generated).

##  Editing oauth.properties

1. Add your app name to the comma-separated list of apps in `oauth.enabledClients` property
2. Add the *hashed* client secret. E.g. if your app clientId is 'MyTestRSpaceApp' then you would add a line:
    `oauth.MyTestRSpaceApp.secret=5f1e48b4aa1da45b2498c8056b7f2c90bcabbcc7c233731f6d23ecfdef3ab741`
3. Add an expiry time, in seconds, for how long generated access tokens. E.g. to store for 365 days:
    `oauth.MyTestRSpaceApp.expiryTime=31536000`
4. Save the file, and restart RSpace

## Getting access tokens

This follows standard OAuth 'password' grant flow.

To acquire a token (details based on above 'oauth.properties' example):

```
export username=myusername
export rspacepwd=rspacepwd
export secret=f1zKVsaaRwudB6+0PnjXtU/JGpweYS5PfWYM50pbVXz2ANU37BNXYx+0k+CsEtLM
export RSPACE_URL=https://myrspace.com

curl -X POST -Fclient_id="app1" -Fgrant_type="password" -Fclient_secret="$secret" -Fusername="$username"\
 -rspacepwd="$rspacepwd"  "$RSPACE_URL/oauth/token"

```
**Note** that the client secret you put in a token request is the _plaintext_ secret, not the hashed version.
This call will return the access token, refresh tokens and a duration, in seconds, for the validity of the access token:

```
{
  "scope" : "all",
  "access_token" : "TuWHW0+8mUauD/y9E0HklZqrHGkA6+34",
  "refresh_token" : "rTdb7EMWXdCCdzZzMLD+EWcoXATmETll",
  "expires_in" : 3153599999
}
```

You can invoke this request as many times as you like - only 1 access token is ever valid for a specific user-appID combination, so repeated invocations of this method will invalidate any existing  access and refresh token.

## Refreshing tokens

Carrying on the example from above....

```
export refreshToken=<myrefreshtoken>
curl -X POST -Fclient_id="app1" -Fgrant_type="refresh_token" -Fclient_secret="$secret" \
 -Frefresh_token="$refreshToken" "$RSPACE_URL/oauth/token"
 ```

will return a new refresh token and access token.
 
## Making API calls

Use your access token as follows to make API calls. 

```
export accessToken=MyAppAccessToken
## list your documents, for example
curl -H"Authorization: Bearer $accessToken" "$RSPACE_URL/api/v1/documents"

```