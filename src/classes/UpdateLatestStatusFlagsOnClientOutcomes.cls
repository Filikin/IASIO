/*
1) Find every Client_Outcome__c for this referral during the month of this Client_Outcome__c, set Final_Status_Month__c to false.
1a) Find the newest Client_Outcome__c for this referral during the month of this Client_Outcome__c, set Final_Status_Month__c to true.

2) Find every Client_Outcome__c for this referral during the quarter of this Client_Outcome__c, set Final_Status_Quarter__c to false.
2a) Find the newest Client_Outcome__c for this referral during the quarter of this Client_Outcome__c, set Final_Status_Quarter__c to true.

3) Find every Client_Outcome__c for this referral during the year of this Client_Outcome__c, set Final_Status_Year__c to false.
3a) Find the newest Client_Outcome__c for this referral during the year of this Client_Outcome__c, set Final_Status_Year__c to true.

4) Find every Client_Outcome__c for this referral, set Final_Status_All_Time__c to false.
4a) Find the newest Client_Outcome__c for this referral, set Final_Status_All_Time__c to true.
*/
public with sharing class UpdateLatestStatusFlagsOnClientOutcomes 
{
	public static Boolean InTrigger = false;

	public UpdateLatestStatusFlagsOnClientOutcomes (List<Client_Outcome__c> newOutcomes)
	{
		if (InTrigger) return; // otherwise recursion
		InTrigger = true;
		Set<ID>referralsSet = new Set<ID>();
		for (Client_Outcome__c oneOutcome: newOutcomes)
		{
			referralsSet.add(oneOutcome.Referral__c);
		}
	
		Map<ID,Client_Outcome__c> outcomesToUpdate = new Map<ID,Client_Outcome__c>(); 
		Map<ID, Client_Referral__c> referrals = new Map<ID, Client_Referral__c>([select ID, (select ID, Referral__c, Placement_Date__c, Final_Status_Month__c, Final_Status_Quarter__c, Final_Status_Year__c, Final_Status_All_Time__c from Client_Placements__r where Placement_Date__c != null order by Placement_Date__c DESC) from Client_Referral__c where ID in :referralsSet]);
		for (Client_Outcome__c oneOutcome: newOutcomes)
		{
			Date startMonth = date.newInstance (oneOutcome.Placement_Date__c.Year(), oneOutcome.Placement_Date__c.Month(), 1);
			Date endMonth = date.newInstance (oneOutcome.Placement_Date__c.Year(), oneOutcome.Placement_Date__c.Month()+1, 1) - 1;
			Date startQuarter = date.newInstance (oneOutcome.Placement_Date__c.Year(), (Integer)math.floor((oneOutcome.Placement_Date__c.Month()-1)/3)*3+1, 1); //=FLOOR((A1-1)/3,1)*3+1
			Date endQuarter = date.newInstance (oneOutcome.Placement_Date__c.Year(), (Integer)(math.floor((oneOutcome.Placement_Date__c.Month()-1)/3)+1)*3+1, 1) - 1; //=(FLOOR((A1-1)/3,1)+1)*3+1
			Date startYear = date.newInstance (oneOutcome.Placement_Date__c.Year(), 1, 1);
			Date endYear = date.newInstance (oneOutcome.Placement_Date__c.Year()+1, 1, 1) - 1;
			List<Client_Outcome__c> referralOutcomes = referrals.get(oneOutcome.Referral__c).Client_Placements__r;
			
			Boolean monthFlagSet = false;
			Boolean quarterFlagSet = false;
			Boolean YearFlagSet = false;
			Boolean AllTimeFlagSet = false;
			for (Client_Outcome__c outcome: referralOutcomes)
			{
				if (!AllTimeFlagSet)
				{
					AllTimeFlagSet = true;
					outcome.Final_Status_All_Time__c = true;
				}
				else
				{
					outcome.Final_Status_All_Time__c = false;
				}
				if (outcome.Placement_Date__c >= startYear && outcome.Placement_Date__c <= endYear)
				{
					if (!YearFlagSet)
					{
						YearFlagSet = true;
						outcome.Final_Status_Year__c = true;
					}
					else
					{
						outcome.Final_Status_Year__c = false;
					}
				}
				if (outcome.Placement_Date__c >= startQuarter && outcome.Placement_Date__c <= endQuarter)
				{
					if (!QuarterFlagSet)
					{
						QuarterFlagSet = true;
						outcome.Final_Status_Quarter__c = true;
					}
					else
					{
						outcome.Final_Status_Quarter__c = false;
					}
				}
				if (outcome.Placement_Date__c >= startMonth && outcome.Placement_Date__c <= endMonth)
				{
					if (!MonthFlagSet)
					{
						MonthFlagSet = true;
						outcome.Final_Status_Month__c = true;
					}
					else
					{
						outcome.Final_Status_Month__c = false;
					}
				}
				outcomesToUpdate.put (outcome.id, outcome);
			}
		}
		update outcomesToUpdate.values();	
		InTrigger = false;
	}
}