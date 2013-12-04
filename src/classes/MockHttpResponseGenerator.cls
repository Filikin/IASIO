@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock 
{
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) 
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{  "meta": {    "model": "client",    "next": "",    "page": 1,    "previous": ""  },  "objects": [    {      "address3": "8",      "emergencyRelationship": "11",      "address1type": "3",      "firstName": "Fred",      "notindb": false,      "phone2": "1",      "lastName": "Smith",      "address2": "7",      "phone1": "12323",      "emergencyNumber": "10",      "created": "2013-06-20 14:23:44",      "address3type": "5",      "phone3": "2",      "emergencyPerson": "9",      "address1": "6",      "nickname": "The Fred",      "ID": "LX-001001",      "address2type": "4"    },    {      "address3": "",      "emergencyRelationship": "",      "address1type": "",      "firstName": "John",      "notindb": true,      "phone2": "",      "lastName": "Doe",      "address2": "",      "phone1": "",      "emergencyNumber": "",      "created": "2013-06-20 14:26:06",      "address3type": "",      "phone3": "",      "emergencyPerson": "",      "address1": "",      "nickname": "",      "ID": "LX-001002",      "address2type": ""    },    {      "address3": "",      "emergencyRelationship": "",      "address1type": "",      "firstName": "Eamon",      "notindb": true,      "phone2": "",      "lastName": "Kelly",      "address2": "",      "phone1": "",      "emergencyNumber": "",      "created": "2013-06-21 13:19:13",      "address3type": "",      "phone3": "",      "emergencyPerson": "",      "address1": "",      "nickname": "",      "ID": "LX-001000",      "address2type": ""    }  ]}');
        res.setStatusCode(200);
        return res;
    }
}