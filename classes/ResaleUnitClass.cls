public class ResaleUnitClass {
    public static Boolean isFirstTime = true;
    public static void cloneUnitAndRelatedRecords(List<Unit__c> unitsToClone) {
        system.debug('unitsToClone. size =' + unitsToClone.size());
        if (unitsToClone.isEmpty()) {
            return; // No units to clone, exit the method
        }
        
        List<Unit__c> unitsToInsert = new List<Unit__c>();
        
        // Create a set to hold the IDs of the related projects and towers
        Set<Id> projectIds = new Set<Id>();
        Set<Id> towerIds = new Set<Id>();
        
        // Iterate through units to collect project and tower names
        for (Unit__c unit : unitsToClone) {
            String RSprojectName = 'RS-' + unit.Project__r.Name;
            system.debug('[17]RSprojectName =' + RSprojectName);
            String RStowerName = 'RS-' + unit.Tower__r.Name;
            system.debug('[19]RStowerName ='+RStowerName);
            Id originalProjectId = unit.Project__c;
            system.debug('[21]originalProjectId ='+originalProjectId);
            Id originalTowerId = unit.Tower__c;
            system.debug('[23]originalTowerId ='+originalTowerId);
            
            Project__c originalProject = [SELECT Id, Name, Entity__c FROM Project__c WHERE Id = :originalProjectId LIMIT 1];
            
            system.debug('##originalProject =' + originalProject);
            Tower__c originalTower = [SELECT Id, Name, Project__c FROM Tower__c WHERE Id = :originalTowerId LIMIT 1];
            
            system.debug('##originalTower =' + originalTower);
            
            // Check if project and tower already exist with RS prefixes
            List<Project__c> existingProject = [SELECT Id, Name FROM Project__c WHERE Name = :RSprojectName LIMIT 1];
            system.debug('[34]existingProject ='+existingProject);
            List<Tower__c> existingTower = [SELECT Id, Name FROM Tower__c WHERE Name = :RStowerName LIMIT 1];
            system.debug('[36]existingTower ='+existingTower);
            
            // If no existing project, clone and insert
            Project__c clonedProject;
            if (existingProject.isEmpty()) {
                clonedProject = originalProject.clone(false, true);
                clonedProject.Name = RSprojectName;
                clonedProject.Entity__c = originalProject.Entity__c;
                insert clonedProject;
                system.debug('[44]clonedProject ='+clonedProject);
                projectIds.add(clonedProject.Id);
                system.debug('[46]clonedProject.id ='+clonedProject.id);
            } else {
                projectIds.add(existingProject[0].Id);
                system.debug('[49]existingProject ='+existingProject[0].id);
            }
            
            // If no existing tower, clone and insert
            if (existingTower.isEmpty()) {
                Tower__c clonedTower = originalTower.clone(false, true);
                clonedTower.Name = RStowerName;
                if(!existingProject.isEmpty()){
                   clonedTower.Project__c = existingProject[0].id; 
                }else{
                clonedTower.Project__c = clonedProject.id;
                }
                insert clonedTower;
                system.debug('[58]clonedTower ='+clonedTower);
                towerIds.add(clonedTower.Id);
                system.debug('[60]clonedTower.id ='+clonedTower.id);
            } else {
                towerIds.add(existingTower[0].Id);
                system.debug('[63]existingTower[0].Id ='+existingTower[0].Id);
            }
        }
        
        // Continue with the cloning of units
        //string RSunitName;
        RecordType rt = [SELECT Id FROM RecordType WHERE sobjecttype = 'Unit__c' AND Name = 'Resale Unit' LIMIT 1];
       // List<Unit__c> existingUnit = [SELECT Id, Name FROM Unit__c WHERE Name = :RSunitName LIMIT 1];
        list<Opportunity>opp  = new list <Opportunity>();
        list<Registration__c> reg = new List <Registration__c>();
        
       // system.debug('existingUnit ='+existingUnit);
        for (Unit__c unit : unitsToClone) {
            opp = [SELECT Id,Unit_Number__c,Total_Demand_to_be_Raised__c,Total_Amount_Realized__c,Total_Payment_Received__c,Percentage_Of_Amount_Paid__c,Expected_Price_for_Resale_of_unit__c,
                   Customer_Expected_Price_per_Sft__c,Available_for_Resale_from__c,Approved_Resale_Price__c,(SELECT Id, Name, Registration_Status__c FROM Registrations__r) FROM opportunity WHERE Unit_Number__c  =:unit.Id ];
            //reg = [select id,Name,Opportunity__c, Registration_Status__c from Registration__c where opportunity__c =:opp[0].id];
            //system.debug('reg id ='+reg[0].id);
            //system.debug('reg opportunity id ='+reg[0].opportunity__c);
            system.debug('Approved Resale Price ='+opp[0].Approved_Resale_Price__c);
            system.debug('opp ='+opp[0].id);
            system.debug('Total_Demand_to_be_Raised__c ='+opp[0].Total_Demand_to_be_Raised__c);
            system.debug('Total Amount Realized ='+opp[0].Total_Amount_Realized__c);
          string RSunitName = 'RS-' + unit.Name;
             List<Unit__c> existingUnit = [SELECT Id, Name FROM Unit__c WHERE Name = :RSunitName LIMIT 1];
            system.debug('existingUnit ='+existingUnit);
            system.debug('RSunitName ='+RSunitName);
            
            if(existingUnit.isEmpty()){
            Unit__c clonedUnit = unit.clone(false, true);
            clonedUnit.Name = 'RS-' + unit.Name;
            clonedUnit.Project__c = projectIds.iterator().next();
            system.debug('[77]ClonedUnit_Project__c ='+clonedUnit.Project__c);
            clonedUnit.Tower__c = towerIds.iterator().next();
            system.debug('[79]ClonedUnit_Tower__c ='+clonedUnit.Tower__c);
            clonedUnit.Unit_Status__c = 'Available';
            clonedUnit.RecordTypeId = rt.Id;
            clonedUnit.Area_in_Sqft__c = unit.Area_in_Sqft__c;
            clonedUnit.Basic_Rate_Per_Sqft__c = unit.Basic_Rate_Per_Sqft__c;
         //   clonedUnit.Available_for_Resale_from__c = opp[0].Available_for_Resale_from__c;
            clonedUnit.Total_Amount_to_be_Collected__c = opp[0].Total_Demand_to_be_Raised__c;
            clonedUnit.Percentage_Of_Amount_Paid__c = opp[0].Percentage_Of_Amount_Paid__c;
            clonedUnit.Expected_Price__c = opp[0].Expected_Price_for_Resale_of_unit__c;
//            clonedUnit.Customer_Expected_Price_per_Sft__c = opp[0].Customer_Expected_Price_per_Sft__c;
          //  clonedUnit.Approved_Resale_Price__c = opp[0].Approved_Resale_Price__c;
           // clonedUnit.Amount_Paid_till_Date__c = opp[0].Total_Amount_Realized__c;
                // Access Registration_Status__c from related Registrations using a loop
                for (Opportunity oppRecord : opp) {
                    for (Registration__c registration : oppRecord.Registrations__r) {
                        if (registration.Registration_Status__c != null) {
                            clonedUnit.Registration_Status__c = registration.Registration_Status__c;
                            //system.debug('Registration Status ='+clonedUnit.Registration_Status__c);
                           // system.debug('@@Registration Status ='+registration.Registration_Status__c);
                            break; // Exit the loop once a value is found
                        }
                    }
                }
            //clonedUnit.Registration_Status__c = reg[0].Registration_Status__c;
            unitsToInsert.add(clonedUnit);
                
            system.debug('[85]clonedUnit ='+clonedUnit);
                system.debug('Cloned unit.id ='+clonedUnit.id);
           
        // Insert cloned units
        insert unitsToInsert;
        system.debug('[90]unitsToInsert ='+unitsToInsert);
             system.debug('Cloned unit.id ='+unitsToInsert[0].id);   
            }else{
                system.debug('Unit Record alreadyExisted with RS Name');
            }
        }
        
    }
}