public class RestHelpers 
{
	public static String getContent(String url)
	{ 
		Http h=new Http(); 
	  	//Instantiate a new HTTP request,specify the method (GET) as well as the endpoint 
	  	HttpRequest req= new HttpRequest(); 
	  	req.setEndpoint(url); 
	  	req.setMethod('GET'); 
	
	  	//Send the request, andreturn a response 
	  	HttpResponse res = h.send(req); 
	  	return res.getBody(); 
	} 

  //Pass in the endpoint to be used 
  public static String postContent(String url, String jsonContent)
  { 
	Http h=new Http(); 
  	//Instantiate a new HTTP request,specify the method (GET) as well as the endpoint 
  	HttpRequest req= new HttpRequest(); 
  	req.setEndpoint(url); 
  	req.setMethod('POST'); 
//  	req.setHeader('X-Api-Version',   '2.0');
  	req.setHeader('key', '12345');
  	req.setHeader('secret', '67890');
  	req.setBody(jsonContent);
  	
  	system.debug(req);
  	//Send the request, andreturn a response 
  	HttpResponse res = h.send(req); 
  	system.debug (res);
  	
  	return res.getBody(); 
  } 
	
}