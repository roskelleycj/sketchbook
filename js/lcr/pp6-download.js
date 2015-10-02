/**
 * Downloads membership information from LCR for the Provo Peak Sixth ward.
 *
 * Expects to find LDS_USERNAME and LDS_PASSWORD defined in the environment.
 */

var USERNAME = process.env.LDS_USER,
    PASSWORD = process.env.LDS_PASSWORD,
    PP6_UNIT_ID = process.env.PP6_UNIT_ID,
    SIGNIN_URL = 'https://signin.lds.org/login.html',
    PP6_MEMBER_INFO_URL = 'https://www.lds.org/htvt/services/v1/' + PP6_UNIT_ID + '/members';


var fs = require('fs'),
    request = require('request');

var getAuthToken = function(username, password, callback) {
  console.log('Authenticating...');
  request({
    method: 'POST',
    url: SIGNIN_URL,
    form: {
      username: username,
      password: password
    }
  }, function(error, response, body) {
    if (error) {
      console.error('There was an error authenticating: ' + error);
      return;
    }

    var authToken = response.headers['set-cookie'][0].split(';')[0];
    // console.log('Auth token: ' + authToken);
    callback(authToken);
  });
};

var downloadMemberData = function(authToken, callback) {
  console.log('Authenticated. Downloading member information...');
  request({
    method: 'GET',
    url: PP6_MEMBER_INFO_URL,
    headers: {
      'Cookie': authToken,
      'Accept': 'application/json'
    }
  }, function(error, response, body) {
    if (error) {
      console.error('There was an error retrieving the member data: ' + error);
      return;
    }

    callback(body);
  });
};

getAuthToken(USERNAME, PASSWORD, function(authToken) {
  downloadMemberData(authToken, function(memberData) {
    console.log('Writing member information to file...');
    fs.writeFile("pp6-info.json", memberData, function(error) {
      if (error) {
        console.error('An error occurred while writing the info file: ' + error);
        return;
      }

      console.log('Member data has been saved to pp6-info.json');
    });
  });
});
