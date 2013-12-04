public with sharing class ReportParametersClass 
{
	public Report_Parameters__c params {get;set;}
	
	public ReportParametersClass ()
	{
		params = new Report_Parameters__c ();
		calculateDefaultDates ();
	}
	
	public PageReference Save()
	{
		PageReference reportPage = new PageReference ('/apex/MonthlyReferralsPage?start=' + params.Start_Date__c.format() + '&end=' + params.End_Date__c.format());
		return reportPage;
	}
	
	private void calculateDefaultDates ()
	{
		Integer reportMonth = system.today().month() - 1;
		Integer reportYear = system.today().year();
		if (reportMonth == 0)
		{
			reportMonth = 12;
			reportYear--;
		}
		params.Start_date__c = Date.newInstance (reportYear, reportMonth, 1);
		params.End_date__c = Date.newInstance (reportYear, reportMonth+1, 1) - 1;
	}
	
}