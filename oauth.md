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
export USERNAME="username"
export PASSWORD="password"
export CLIENT_ID="id"
export CLIENT_SECRET="secret"
export RSPACE_URL=https://REPLACE.researchspace.com

curl -X POST -Fgrant_type="password" -Fclient_id="$CLIENT_ID" \
 -Fclient_secret="$CLIENT_SECRET" -Fusername="$USERNAME" \
 -Fpassword="$PASSWORD" "$RSPACE_URL/oauth/token"
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
export REFRESH_TOKEN=rTdb7EMWXdCCdzZzMLD+EWcoXATmETll

curl -X POST -Fgrant_type="refresh_token" -Fclient_id="$CLIENT_ID" \
 -Fclient_secret="$CLIENT_SECRET" -Frefresh_token="$REFRESH_TOKEN" "$RSPACE_URL/oauth/token"
 ```

Will return a new refresh token and access token.

## JWT tokens

We also support JWT token generation. To obtain a JWT token, add `-Fis_jwt="true"` to `password` or `refresh_token` grant types.

```bash
curl -X POST -Fgrant_type="password" -Fclient_id="$CLIENT_ID" \
 -Fclient_secret="$CLIENT_SECRET" -Fusername="$USERNAME" \
 -Fpassword="$PASSWORD" -Fis_jwt="true" "$RSPACE_URL/oauth/token"
```

You can generate as many JWT tokens as you like - all of them will be valid until expiry, and until the refresh token is not updated.

JWT tokens have been implemented in a way that does not interfere with the normal access and refresh token generation workflow. Hence if a JWT is requested for an already existing access/refresh token pair, assume the unhashed refresh token is known and do not return in in the response body. In addition, grant type of `refresh_token` with `is_jwt` parameter will return a new JWT token, but will not update the refresh token.

## Making API calls

Use your access token as follows to make API calls.

```bash
export ACCESS_TOKEN=TuWHW0+8mUauD/y9E0HklZqrHGkA6+34
## for example, list your documents
curl -H"Authorization: Bearer $ACCESS_TOKEN" "$RSPACE_URL/api/v1/documents"
```
