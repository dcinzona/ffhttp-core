/**
 * Copyright (c) 2014, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/
 
/**
 * ffhttp_ClientTest
 *
 * Test class for the ffhttp 'package'.
 */
@isTest
private class ffhttp_ClientTest 
{	
	/**
	 * Check that you can create a valid credentials object
	 */
	static testMethod void testCredentials()
	{
		ffhttp_Client.Credentials credentials = new ffhttp_Client.Credentials('Bearer', 'Test');
		
		System.assertEquals(credentials.getTokenType(), 'Bearer');
		System.assertEquals(credentials.getAccessToken(), 'Test');
		
		credentials.setTokenType('Basic')
				   .setAccessToken('Testing');
		
		System.assertEquals(credentials.getTokenType(), 'Basic');
		System.assertEquals(credentials.getAccessToken(), 'Testing');
	}
	
	/**
	 * Check that you cannot create a credentials object with a null AccessToken.
	 */
	static testMethod void testInvalidCredentials()
	{
		try
		{
			ffhttp_Client.Credentials credentials = new ffhttp_Client.Credentials(null, null);
		}
		catch (ffhttp_SystemException ex)
		{
			System.assertEquals(ex.getMessage(), 'TokenType cannot be null');
			
			try
			{
				ffhttp_Client.Credentials credentials = new ffhttp_Client.Credentials('Basic', null);
			}
			catch (ffhttp_SystemException ex2)
			{
				System.assertEquals(ex2.getMessage(), 'AccessToken cannot be null');
				return;
			}
			
			System.assert(false, 'SystemException 2 was not thrown');
		}
		
		System.assert(false, 'SystemException was not thrown');
	}
	
	/**
	* Check that JsonSerializable correctly serializes an object.
	*/
	static testMethod void testJsonSerializable()
	{
		JsonTest jsonBody = new JsonTest();
		System.assertEquals(jsonBody.getHttpContentType(), 'application/json; charset=UTF-8');

		String serializedBody = jsonBody.serialize();
		System.assertEquals(serializedBody, '{"test":"Test"}');

		serializedBody = (String)jsonBody.getHttpContent();
		System.assertEquals(serializedBody, '{"test":"Test"}');
	}

	/**
	 * Check that ffhttp_JsonDeserializer correctly deserializes an object
	 */
	static testMethod void testJsonDeserializer()
	{
		JsonTest test = new JsonTest();

		ffhttp_JsonDeserializer jds = new ffhttp_JsonDeserializer(JsonTest.class);
		System.assert(jds != null, 'ffhttp_JsonDeserializer should not be null');

		JsonTest test2 = (JsonTest)jds.deserialize('{"test":"Test"}');
		System.assertEquals(test2.getTest(), 'Test');
	}

	/**
	 * Check that ffhttp_JsonDeserializer throws an exception for invalid JSON
	 */
	static testMethod void testJsonDeserializerWithInvalidJson()
	{
		JsonTest test = new JsonTest();

		ffhttp_JsonDeserializer jds = new ffhttp_JsonDeserializer(JsonTest.class);
		System.assert(jds != null, 'ffhttp_JsonDeserializer should not be null');

		try 
		{
			JsonTest test2 = (JsonTest)jds.deserialize('{"invalid json test}');
		}
		catch (Exception e)
		{
			System.assert(e instanceOf ffhttp_SystemException, 'ffhttp_SystemException should be thrown');
			return;
		}

		System.assert(false, 'A ffhttp_SystemException was not thrown');
	}

	/**
	 * Check that ffhttp_JsonDeserializer correctly deserializes a string with a field to replace
	 */
	static testMethod void testJsonDeserializerWithAFieldToReplace()
	{
		Map<String, String> fieldsToReplace = new Map<String, String>();
		fieldsToReplace.put('testing', 'test');

		ffhttp_JsonDeserializer jds = new ffhttp_JsonDeserializer(JsonTest.class, fieldsToReplace);

		JsonTest test = (JsonTest)jds.deserialize('{"testing":"Test"}');
		System.assertEquals(test.getTest(), 'Test');
	}

	/**
	 * Check that ffhttp_JsonDeserializer correctly deserializes a string with multiple fields to replace
	 */
	static testMethod void testJsonDeserializerWithMultipleFieldsToReplace()
	{
		Map<String, String> fieldsToReplace = new Map<String, String>();
		fieldsToReplace.put('testing', 'test');
		fieldsToReplace.put('testing2', 'test2');

		ffhttp_JsonDeserializer jds = new ffhttp_JsonDeserializer(JsonTest2.class, fieldsToReplace);

		JsonTest2 test = (JsonTest2)jds.deserialize('{"testing":"Test","testing2":"Test2"}');
		System.assertEquals(test.getTest(), 'Test');
		System.assertEquals(test.getTest2(), 'Test2');
	}

	/**
	 * Check that ffhttp_JsonDeserializer replaces all fields with the same name
	 */
	static testMethod void testJsonDeserializerWithFieldsToReplaceCreatingDuplicate()
	{
		Map<String, String> fieldsToReplace = new Map<String, String>();
		fieldsToReplace.put('testing', 'test');

		ffhttp_JsonDeserializer jds = new ffhttp_JsonDeserializer(JsonTest.class, fieldsToReplace);

		try 
		{
			JsonTest test = (JsonTest)jds.deserialize('{"testing":"Test","testing":"Test"}');
		}
		catch (Exception e)
		{
			System.assert(e instanceOf ffhttp_SystemException, 'ffhttp_SystemException should be thrown');
			System.assert(e.getCause() instanceOf System.JSONException, 'System.JSONException should be the cause');
			return;
		}

		System.assert(false, 'A ffhttp_SystemException was not thrown');
	}

	/**
	 * Check that to send a ffhttp_Client request the AbstractClient must be set.
	 */
	static testMethod void testRequestNoClient()
	{
		HttpClientRequest request = new HttpClientRequest();
		
		try
		{
			request.buildHttpRequest();
		}
		catch (Exception ex)
		{
			System.assert(ex instanceOf ffhttp_SystemException, 'A ffhttp_SystemException was not thrown.');
			System.assertEquals(ex.getMessage(), 'AbstractClient not set');
			return;
		}
		
		System.assert(false, 'A ffhttp_SystemException was not thrown');
	}
	
	/**
	 * Check that to send a ffhttp_Client request the Credentials must be set.
	 */
	static testMethod void testRequestNoCredentials()
	{
		HttpClient client = new HttpClient();
		System.assertEquals(client.getCredentialsRequired(), true);
		
		HttpClientRequest request = new HttpClientRequest(client, null, null, null, null);
		 
		try
		{
			request.buildHttpRequest();
		}
		catch (Exception ex)
		{
			System.assert(ex instanceOf ffhttp_SystemException, 'A ffhttp_SystemException was not thrown.');
			System.assertEquals(ex.getMessage(), 'AbstractClient.Credentials not set');
			return;
		}
		
		System.assert(false, 'A ffhttp_SystemException was not thrown');
	}
	
	/**
	 * Check that buildHttpRequest correctly builds the request URL.
	 */
	static testMethod void testRequestUrl()
	{
		HttpClientRequest clientRequest = getDefaultClientRequest();
		HttpRequest request = clientRequest.buildHttpRequest();
		
		System.assertEquals(request.getEndpoint(), 'TestEndpoint');
		System.assertEquals(request.getMethod(), 'POST');
	}
	
	private static HttpClientRequest getDefaultClientRequest()
	{
		HttpClient client = new HttpClient();
		ffhttp_Client.Credentials credentials = new ffhttp_Client.Credentials('Basic', 'Test Credentials');
		client.setCredentials(credentials);
		
		return new HttpClientRequest(client, 'TestEndpoint', 'POST', null, null);
	}
	
	/**
	 * Test each of the addParam/getParam methods 
	 */
	static testMethod void testRequestStringParameters()
	{
		HttpClientRequest clientRequest = getDefaultClientRequest();
		HttpRequest request = clientRequest.buildHttpRequest();
		
		String stringtest = clientRequest.getParam('StringTest', 'Test Default');
		System.assertEquals(stringTest, 'Test Default');
		
		stringtest = clientRequest.getParam('StringTest');
		System.assertEquals(stringTest, null);
		
		clientRequest.addParam('StringTest', 'Test');
		stringtest = clientRequest.getParam('StringTest', 'Testing');
		System.assertEquals(stringTest, 'Test');
		
		request = clientRequest.buildHttpRequest();
		System.assertEquals(request.getEndpoint(), 'TestEndpoint?StringTest=Test');
		
		stringtest = clientRequest.getParam('StringTest');
		System.assertEquals(stringTest, 'Test');
	}
	
	static testMethod void testRequestBooleanParameters()
	{
		HttpClientRequest clientRequest = getDefaultClientRequest();
		clientRequest.addParam('BooleanTrueTest', true);
		clientRequest.addParam('BooleanFalseTest', false);
		clientRequest.addParam('BooleanNullTest', (Boolean)null);
		
		boolean booleanTrueTest = clientRequest.getParam('BooleanTrueTest', false);
		System.assertEquals(booleanTrueTest, true);
		
		boolean booleanFalseTest = clientRequest.getParam('BooleanFalseTest', true);
		System.assertEquals(booleanFalseTest, false);
		
		boolean booleanNullTest = clientRequest.getParam('BooleanNullTest', false);
		System.assertEquals(booleanNullTest, false);
		
		HttpRequest request = clientRequest.buildHttpRequest();
		System.assertEquals(request.getEndpoint(), 'TestEndpoint?BooleanTrueTest=true&BooleanFalseTest=false');
	}
	
	static testMethod void testRequestIntegerParameters()
	{
		HttpClientRequest clientRequest = getDefaultClientRequest();
		clientRequest.addParam('IntegerPositiveTest', 10);
		clientRequest.addParam('IntegerNegativeTest', -10);
		clientRequest.addParam('IntegerNullTest', (Integer)null);
		
		Integer integerPostiveTest = clientRequest.getParam('IntegerPositiveTest', 50);
		System.assertEquals(integerPostiveTest, 10);
		
		Integer integerNegativeTest = clientRequest.getParam('IntegerNegativeTest', -50);
		System.assertEquals(integerNegativeTest, -10);
		
		Integer integerNullTest = clientRequest.getParam('IntegerNullTest', 40);
		System.assertEquals(integerNullTest, 40);
		
		HttpRequest request = clientRequest.buildHttpRequest();
		System.assertEquals(request.getEndpoint(), 'TestEndpoint?IntegerPositiveTest=10&IntegerNegativeTest=-10');
	}
	
	static testMethod void testRequestLongParameters()
	{
		HttpClientRequest clientRequest = getDefaultClientRequest();
		clientRequest.addParam('LongPositiveTest', Long.valueOf('10'));
		clientRequest.addParam('LongNegativeTest', Long.valueOf('-10'));
		clientRequest.addParam('LongNullTest', (Long)null);
		
		Long longPostiveTest = clientRequest.getParam('LongPositiveTest', Long.valueOf('50'));
		System.assertEquals(longPostiveTest, 10);
		
		Long longNegativeTest = clientRequest.getParam('LongNegativeTest', Long.valueOf('-50'));
		System.assertEquals(longNegativeTest, -10);
		
		Long longNullTest = clientRequest.getParam('LongNullTest', Long.valueOf('40'));
		System.assertEquals(longNullTest, 40);
		
		HttpRequest request = clientRequest.buildHttpRequest();
		System.assertEquals(request.getEndpoint(), 'TestEndpoint?LongPositiveTest=10&LongNegativeTest=-10');
	}
	
	/**
	 * Check that the request body is correctly set for blob content and json content.
	 */
	static testMethod void testRequestBody()
	{
		HttpClient client = new HttpClient();
		client.setCredentialsRequired(false);
		
		Blob b = Blob.valueOf('{ title=Test }');
		ffhttp_BlobContent jsonContent = new ffhttp_BlobContent(b, 'application-json');
		
		HttpClientRequest clientRequest = new HttpClientRequest(client, 'TestEndpoint', 'POST', jsonContent, null);
		HttpRequest request = clientRequest.buildHttpRequest();
		
		System.assertEquals(request.getHeader('Content-Type'), 'application-json');
		System.assertEquals(request.getBodyAsBlob(), b);
		System.assertEquals(request.getHeader('Content-Length'), '14');
		
		JsonTest jsonBody = new JsonTest();
		clientRequest = new HttpClientRequest(client, 'TestEndpoint', 'POST', jsonBody, null);
		request = clientRequest.buildHttpRequest();
		
		System.assertEquals(request.getHeader('Content-Type'), 'application/json; charset=UTF-8');
		System.assertEquals(request.getBody(), '{"test":"Test"}');
		System.assertEquals(request.getHeader('Content-Length'), '15');
	}
	
	/**
	 * Check that a request with a valid response is dealt with appropriately.
	 */
	static testMethod void testExecuteValidResponse()
	{
		HttpClient client = new HttpClient();
		client.setCredentialsRequired(false);
		
		Test.setMock(HttpCalloutMock.class, new HttpResponseSuccess());

		HttpClientRequest clientRequest = new HttpClientRequest(client, 'TestEndpoint', 'POST', null, new ffhttp_JsonDeserializer(JsonTest.class));
				
		Object response = clientRequest.execute();
		System.assert(response != null, 'Response should not be null');
		System.assert(response instanceof JsonTest, 'Response should be an instance of JsonTest');
		System.assertEquals(((JsonTest)response).getTest(), 'Test');
	}
	
	/**
	 * Check that if we get an invalid response an ffhttp_AppException is thrown.
	 */
	static testMethod void testExecuteInvalidResponse()
	{
		HttpClient client = new HttpClient();
		client.setCredentialsRequired(false);
		
		Test.setMock(HttpCalloutMock.class, new HttpResponseFailure());

		HttpClientRequest clientRequest = new HttpClientRequest(client, 'TestEndpoint', 'POST', null, null);
		
		try
		{
			Object response = clientRequest.execute();
		}
		catch (Exception ex)
		{
			System.assert(ex instanceOf ffhttp_AppException, 'An ffhttp_AppException was not thrown.');
			
			ffhttp_AppException ae = (ffhttp_AppException)ex;
			System.assertEquals(ae.getMessage(), 'Invalid Request');
			System.assertEquals(ae.getStatus(), 'Invalid Request');
			System.assertEquals(ae.getStatusCode(), 400);
			return;
		}
		
		System.assert(false, 'An ffhttp_AppException was not thrown');
	}
	
	/**
	 * Test that you can create a BlobContent instance correctly
	 */
	static testMethod void testCreateBlobContent() 
	{		
		Blob b = Blob.valueOf('Testing');
		
		ffhttp_BlobContent jsonContent = new ffhttp_BlobContent(b, 'application-json');
		
		System.assertEquals(jsonContent.getHttpContent(), b);
		System.assertEquals(jsonContent.getHttpContentType(), 'application-json');
	}
	
	/**
	 * Test that if you try and create a BlobContent instance with a null Blob an exception is thrown
	 */
	static testMethod void testInvalidBlobContent() 
	{
		try 
		{
			ffhttp_BlobContent jsonContent = new ffhttp_BlobContent(null, 'application-json');
		}
		catch (ffhttp_SystemException ex) 
		{
			System.assertEquals(ex.getMessage(), 'Blob cannot be null');
			return;
		}
		
		System.assert(false, 'ffhttp_SystemException was not thrown');
	}
	
	/**
	 * Test that if you try and create a BlobContent instance with no content type an exception is thrown
	 */
	static testMethod void testInvalidBlobContentType() 
	{
		try
	 	{
			Blob b = Blob.valueOf('Testing');
			ffhttp_BlobContent jsonContent = new ffhttp_BlobContent(b, null);
		}
		catch (ffhttp_SystemException ex) 
		{
			System.assertEquals(ex.getMessage(), 'ContentType cannot be null');
			return;
		}
		
		System.assert(false, 'ffhttp_SystemException was not thrown');
	}
	
	/**
	 * ffhttp_OAuthClient tests
	 */
	static testMethod void testOAuthClient()
	{
		ffhttp_OAuthClient client = new ffhttp_OAuthClient();
		
		String url = client.generateAuthorizationUrl(new MockConnectorType(), 'teststate');
		System.assert(url.equals('https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=35780030306-f9tvdjig5av01uashtnhkkfmtdghh3di.apps.googleusercontent.com&redirect_uri=https%3A%2F%2Feu3.salesforce.com%2Fapex%2Fconnector&state=teststate&access_type=offline&approval_prompt=force'));
	
		ffhttp_OAuthClient.ExchangeAuthCodeRequest authCodeRequest = client.exchangeAuthCodeRequest(new MockConnectorType(), 'testcode');
		HttpRequest request = authCodeRequest.buildHttpRequest();
		System.assertEquals(request.getHeader('Content-Type'), 'application/x-www-form-urlencoded');
		System.assertEquals(request.getBody(), 'code=testcode&grant_type=authorization_code&client_id=35780030306-f9tvdjig5av01uashtnhkkfmtdghh3di.apps.googleusercontent.com&client_secret=Exd29I0NjExkm6RDFR-MY-Gx&redirect_uri=https%3A%2F%2Feu3.salesforce.com%2Fapex%2Fconnector');
	
		ffhttp_OAuthClient.ExchangeRefreshTokenRequest refreshTokenRequest = client.exchangeRefreshTokenRequest(new MockConnectorType(), 'testRefreshToken');
		request = refreshTokenRequest.buildHttpRequest();
		System.assertEquals(request.getHeader('Content-Type'), 'application/x-www-form-urlencoded');
		System.assertEquals(request.getBody(), 'grant_type=refresh_token&client_id=35780030306-f9tvdjig5av01uashtnhkkfmtdghh3di.apps.googleusercontent.com&client_secret=Exd29I0NjExkm6RDFR-MY-Gx&redirect_uri=https%3A%2F%2Feu3.salesforce.com%2Fapex%2Fconnector&refresh_token=testRefreshToken');
	
		Test.setMock(HttpCalloutMock.class, new OAuthHttpResponse());
	
		ffhttp_OAuthClient.AccessTokenResponse authTokenResponse = (ffhttp_OAuthClient.AccessTokenResponse)authCodeRequest.execute();
		System.assertEquals(authTokenResponse.access_token, '1/fFAGRNJru1FTz70BzhT3Zg');
		System.assertEquals(authTokenResponse.expires_in, 3920);
		System.assertEquals(authTokenResponse.token_type, 'Bearer');
		System.assertEquals(authTokenResponse.refresh_token, '1/xEoDL4iW3cxlI7yDbSRFYNG01kVKM2C-259HOF2aQbI');
	}
	
	/**
	 * ffhttp_MultipartMimeAttachment tests
	 */
	static testMethod void testMultipartMimeAttachment()
    {
        Blob fileABlob = EncodingUtil.base64Decode('/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQECAgICAgICAgICAgMDAwMDAwMDAwP/2wBDAQEBAQEBAQIBAQICAgECAgMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwP/wAARCAAKAAoDAREAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAP/xAAmEAAAAwMNAAAAAAAAAAAAAAAAFhfI6PAYKCk2R2ZnaoaJmKn4/8QAFAEBAAAAAAAAAAAAAAAAAAAAAP/EABQRAQAAAAAAAAAAAAAAAAAAAAD/2gAMAwEAAhEDEQA/AJ1euwWNClEi8WE6TqSxg6S0dsdR2joB5Hcmdd6ywCJo7EzLu2WARGQDAf/Z');
        Blob fileBBlob = EncodingUtil.base64Decode('/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQECAgICAgICAgICAgMDAwMDAwMDAwP/2wBDAQEBAQEBAQIBAQICAgECAgMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwP/wAARCAAKAAoDAREAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAX/xAAkEAABAwIFBQEAAAAAAAAAAAAFAwQHAgYACMjo8Akoaomp+P/EABYBAQEBAAAAAAAAAAAAAAAAAAADBf/EABwRAAMBAQEBAQEAAAAAAAAAAAECAwQABREhEv/aAAwDAQACEQMRAD8AigArOOQQW3RyxYAPjkSNCsXB8+dHnbYZxgzRYtljV0XQSy43NbxaP0MqNNTl+RdxO/thaHqlnC0RKxBXX06ZQimaCZ5lzOaBQWZnYhR8H9O5Z3b4P1nZmY/rEkk9oet6en2vV0+xsXOmvXopZ1hCGWCvVy7COXLOObNIMxE4Z5ShFPk5TSaqorfkfZNtd+ZeK9n852j6JtLvrLw5znPADw53/9k=');
        Blob fileCBlob = EncodingUtil.base64Decode('/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQECAgICAgICAgICAgMDAwMDAwMDAwP/2wBDAQEBAQEBAQIBAQICAgECAgMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwP/wAARCAAMAAwDAREAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAP/xAAtEAAAAgQLCQAAAAAAAAAAAAAWFwA3OGcYGSk2OUdJZoen8Gl3hoiJmKi4x//EABQBAQAAAAAAAAAAAAAAAAAAAAD/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCc3rsBjgUIgXtYLouoLDnQWTtTpOydAHc5WeKqg8m2TnN7OJAbucLPgbKvKcpvBuziQHrVrpLUS2ot1A//2Q==');
        
        ffhttp_MultipartMimeAttachment body1 = new ffhttp_MultipartMimeAttachment();
        body1.writeBoundary();
        body1.writeBodyParameter('key', 'value');
        body1.writeBoundary();
        body1.writeFile('key', 'value', 'image/jpeg', fileABlob);
        body1.writeEndBoundary();

        ffhttp_MultipartMimeAttachment body2 = new ffhttp_MultipartMimeAttachment();
        body2.writeBoundary();
        body2.writeBodyParameter('key', 'value');
        body2.writeBoundary();
        body2.writeFile('key', 'value', 'image/jpeg', fileBBlob);
        body2.writeEndBoundary();

        ffhttp_MultipartMimeAttachment body3 = new ffhttp_MultipartMimeAttachment();
        body3.writeBoundary();
        body3.writeBodyParameter('key', 'value');
        body3.writeBoundary();
        body3.writeFile('key', 'value', 'image/jpeg', fileCBlob);
        body3.writeEndBoundary();

        System.assertEquals(body1.getHttpContentType(), 'multipart/form-data; charset="UTF-8"; boundary="1ff13444ed8140c7a32fc4e6451aa76d"');
        System.assertEquals(EncodingUtil.base64Encode((Blob)body1.getHttpContent()), 'LS0xZmYxMzQ0NGVkODE0MGM3YTMyZmM0ZTY0NTFhYTc2ZA0KQ29udGVudC1EaXNwb3NpdGlvbjogZm9ybS1kYXRhOyBuYW1lPSJrZXkiICANCg0KdmFsdWUgIA0KLS0xZmYxMzQ0NGVkODE0MGM3YTMyZmM0ZTY0NTFhYTc2ZA0KQ29udGVudC1EaXNwb3NpdGlvbjogZm9ybS1kYXRhOyBuYW1lPSJrZXkiOyBmaWxlbmFtZT0idmFsdWUiIA0KQ29udGVudC1UeXBlOiBpbWFnZS9qcGVnICANCg0K/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQECAgICAgICAgICAgMDAwMDAwMDAwP/2wBDAQEBAQEBAQIBAQICAgECAgMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwP/wAARCAAKAAoDAREAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAP/xAAmEAAAAwMNAAAAAAAAAAAAAAAAFhfI6PAYKCk2R2ZnaoaJmKn4/8QAFAEBAAAAAAAAAAAAAAAAAAAAAP/EABQRAQAAAAAAAAAAAAAAAAAAAAD/2gAMAwEAAhEDEQA/AJ1euwWNClEi8WE6TqSxg6S0dsdR2joB5Hcmdd6ywCJo7EzLu2WARGQDAf/ZDQotLTFmZjEzNDQ0ZWQ4MTQwYzdhMzJmYzRlNjQ1MWFhNzZkLS0=');
        System.assertEquals(EncodingUtil.base64Encode((Blob)body2.getHttpContent()), 'LS0xZmYxMzQ0NGVkODE0MGM3YTMyZmM0ZTY0NTFhYTc2ZA0KQ29udGVudC1EaXNwb3NpdGlvbjogZm9ybS1kYXRhOyBuYW1lPSJrZXkiICANCg0KdmFsdWUgIA0KLS0xZmYxMzQ0NGVkODE0MGM3YTMyZmM0ZTY0NTFhYTc2ZA0KQ29udGVudC1EaXNwb3NpdGlvbjogZm9ybS1kYXRhOyBuYW1lPSJrZXkiOyBmaWxlbmFtZT0idmFsdWUiIA0KQ29udGVudC1UeXBlOiBpbWFnZS9qcGVnICANCg0K/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQECAgICAgICAgICAgMDAwMDAwMDAwP/2wBDAQEBAQEBAQIBAQICAgECAgMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwP/wAARCAAKAAoDAREAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAX/xAAkEAABAwIFBQEAAAAAAAAAAAAFAwQHAgYACMjo8Akoaomp+P/EABYBAQEBAAAAAAAAAAAAAAAAAAADBf/EABwRAAMBAQEBAQEAAAAAAAAAAAECAwQABREhEv/aAAwDAQACEQMRAD8AigArOOQQW3RyxYAPjkSNCsXB8+dHnbYZxgzRYtljV0XQSy43NbxaP0MqNNTl+RdxO/thaHqlnC0RKxBXX06ZQimaCZ5lzOaBQWZnYhR8H9O5Z3b4P1nZmY/rEkk9oet6en2vV0+xsXOmvXopZ1hCGWCvVy7COXLOObNIMxE4Z5ShFPk5TSaqorfkfZNtd+ZeK9n852j6JtLvrLw5znPADw53/9kNCi0tMWZmMTM0NDRlZDgxNDBjN2EzMmZjNGU2NDUxYWE3NmQtLQ==');
        System.assertEquals(EncodingUtil.base64Encode((Blob)body3.getHttpContent()), 'LS0xZmYxMzQ0NGVkODE0MGM3YTMyZmM0ZTY0NTFhYTc2ZA0KQ29udGVudC1EaXNwb3NpdGlvbjogZm9ybS1kYXRhOyBuYW1lPSJrZXkiICANCg0KdmFsdWUgIA0KLS0xZmYxMzQ0NGVkODE0MGM3YTMyZmM0ZTY0NTFhYTc2ZA0KQ29udGVudC1EaXNwb3NpdGlvbjogZm9ybS1kYXRhOyBuYW1lPSJrZXkiOyBmaWxlbmFtZT0idmFsdWUiIA0KQ29udGVudC1UeXBlOiBpbWFnZS9qcGVnICANCg0K/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQECAgICAgICAgICAgMDAwMDAwMDAwP/2wBDAQEBAQEBAQIBAQICAgECAgMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwP/wAARCAAMAAwDAREAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAP/xAAtEAAAAgQLCQAAAAAAAAAAAAAWFwA3OGcYGSk2OUdJZoen8Gl3hoiJmKi4x//EABQBAQAAAAAAAAAAAAAAAAAAAAD/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCc3rsBjgUIgXtYLouoLDnQWTtTpOydAHc5WeKqg8m2TnN7OJAbucLPgbKvKcpvBuziQHrVrpLUS2ot1A//2Q0KLS0xZmYxMzQ0NGVkODE0MGM3YTMyZmM0ZTY0NTFhYTc2ZC0t');
    }

	/************************************************************************************************************
	 * Test classes
	 ************************************************************************************************************/
	
	class JsonTest extends ffhttp_AbstractJsonSerializable
	{
		private String test = 'Test';
		
		public String getTest()
		{
			return test;
		}
	}

	class JsonTest2 extends ffhttp_AbstractJsonSerializable
	{
		private String test = 'Test';
		private String test2 = 'Test2';
		
		public String getTest()
		{
			return test;
		}
		public String getTest2()
		{
			return test2;
		}
	}
	
	class HttpClient extends ffhttp_Client.AbstractClient
	{
		
	}
	
	/**
	 * MockConnectorType test class
	 *
	 * Mocks the Google OAuth Authorization information
	 */
	class MockConnectorType implements ffhttp_IConnectorType
	{
		public String getAuthorizationEndpoint()
		{
			return 'https://accounts.google.com/o/oauth2/auth';
		}
	
		public String getTokenEndpoint()
		{
			return 'https://accounts.google.com/o/oauth2/token';
		}
	
		public String getClientId()
		{
			return '35780030306-f9tvdjig5av01uashtnhkkfmtdghh3di.apps.googleusercontent.com';
		}
	
		public String getClientSecret()
		{
			return 'Exd29I0NjExkm6RDFR-MY-Gx';
		}
	
		public String getRedirectUri()
		{
			return 'https://eu3.salesforce.com/apex/connector';
		}
	
		public String getExtraUrlParameters()
		{
			return 'access_type=offline&approval_prompt=force';
		}
	}
	
	/**
	 * Mock success HTTP response
	 */
	class HttpResponseSuccess implements HttpCalloutMock
	{
		 public HttpResponse respond(HTTPRequest req) 
		 {
		    HttpResponse res = new HttpResponse();
		    res.setStatus('OK');
		    res.setStatusCode(200);
		    res.setBody('{"test":"Test"}');
		    return res;
		 }
	}
	
	/**
	 * Mock failure HTTP response
	 */
	class HttpResponseFailure implements HttpCalloutMock
	{
		 public HttpResponse respond(HTTPRequest req) 
		 {
		    HttpResponse res = new HttpResponse();
		    res.setStatus('Invalid Request');
		    res.setStatusCode(400);
		    return res;
		 }
	}
	
	/**
	 * Mock respobse for OAuth authorisation 
	 */
	class OAuthHttpResponse implements HttpCalloutMock
	{
		public HttpResponse respond(HTTPRequest req) 
		{
		    HttpResponse res = new HttpResponse();
		    res.setBody('{"access_token":"1/fFAGRNJru1FTz70BzhT3Zg","expires_in":3920,"token_type":"Bearer","refresh_token":"1/xEoDL4iW3cxlI7yDbSRFYNG01kVKM2C-259HOF2aQbI"}');
		    res.setStatusCode(200);
		    return res;
		 }	 
	}
	
	class HttpClientRequest extends ffhttp_Client.AbstractClientRequest
	{
		public HttpClientRequest()
		{
		}
		
		public HttpClientRequest(AbstractClient abstractClient, String endpoint, String requestMethod, 
						  		 ffhttp_IHttpContent httpContent, ffhttp_IDeserialize responseDeserializer) 
		{ 
			super(abstractClient, endpoint, requestMethod, httpContent, responseDeserializer);
		}
	}
}