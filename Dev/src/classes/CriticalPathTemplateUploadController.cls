public class CriticalPathTemplateUploadController {

    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public string fname {get; set;}
    public String[] csvFileLines{get;set;}   
    public pse__proj__c proj{get;set;}  
    public Integer validLinesToProcess{get; set;}
    
    public void importCSVFile(){
        
        csvFileLines = new String[]{};         
        Savepoint sp = Database.setSavepoint();
        
        try {                        
            
            // Create project
            proj = new pse__proj__c();
            proj.name = fname.replace('.csv','');
            proj.pse__Is_Template__c = TRUE;
            proj.pse__Is_Active__c = TRUE;
            insert proj;
            System.debug('Project inserted - ' + proj);
            
            csvAsString = csvFileBody.toString();
            csvFileLines = csvAsString.split('\n'); 
            
            System.debug('Number of lines in CSV file : ' + csvFileLines.size());
            
            validLinesToProcess = 0;
            
            List<pse__project_task__c> taskList = New List<pse__project_task__c>();
            Map<String,pse__project_task__c> taskMap = new Map<String,pse__project_task__c>();
            Map<String,String> parentTaskMap = new Map<String,String>();            
            
            for(Integer i=0;i<csvFileLines.size();i++){
                
                String csvLine = csvFileLines[i]; 
                String[] fields = csvLine.split(',');  
                List<String> cleanFields = new List<String>();
                String compositeField;
                Boolean makeCompositeField = false;
                for(String field : fields) {
                    if (field.startsWith('"') && field.endsWith('"')) {
                        cleanFields.add(field.replaceAll('DBLQT','"'));
                    } else if (field.startsWith('"')) {
                        makeCompositeField = true;
                        compositeField = field;
                    } else if (field.endsWith('"')) {
                        compositeField += ',' + field;
                        cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                        makeCompositeField = false;
                    } else if (makeCompositeField) {
                        compositeField +=  ',' + field;
                    } else {
                        cleanFields.add(field.replaceAll('DBLQT','"'));
                    }
                }                                  
                
                String taskType = (cleanFields != null && cleanFields.size() >= 10 && cleanFields[9].trim().length() > 0) ? cleanFields[9] : '';                
                if (taskType.trim().length() == 0)
                    continue;
                else {
                    validLinesToProcess++;
                    System.debug(csvLine);                                           
                                        
                    // Create tasks
                    pse__Project_Task__c task = new pse__Project_Task__c();
                    task.pse__Project__c = proj.ID;                  
                    if (cleanFields[0].trim().length() > 0) task.name = cleanFields[0].replace('"','');
                    else task.name = cleanFields[1].replace('"','');
                    if (cleanFields[9].containsIgnoreCase('KM')) task.Key_Delivery_Milestone__c = TRUE;
                    if (!String.isBlank(cleanFields[8])) task.pse__Description__c = cleanFields[8].replace('"','');
                    
                    System.debug(cleanFields[9] + ' - ' + task);
                    
                    taskMap.put(cleanFields[9].trim(),task);
                    System.debug(taskMap);
                    
                    System.debug(cleanFields.size());
                    
                    //Added new --Deepak Malkani --FOR future reference if we do not want to add parent template tasks
                    //if(cleanFields.size() > 10){
                        if (!String.isEmpty(cleanFields[10]) && cleanFields[10].trim().length() > 0)
                            parentTaskMap.put(cleanFields[9].trim(),cleanFields[10].trim());
                    //}                                        
                }                
            }                     
            
            // Insert all tasks
            insert taskMap.values();
            System.debug('Inserted total tasks : ' + taskMap.values().size());
            
            // Set parent task where applicable
            for (String key : parentTaskMap.keySet()) {
                System.debug('key : ' + key);
                String parentKey = parentTaskMap.get(key);
                System.debug('parent key : ' + parentKey);
                pse__project_task__c task = taskMap.get(key);
                System.debug('task : ' + task);
                pse__project_task__c parentTask = taskMap.get(parentKey);
                System.debug('parent task : ' + parentTask);
                task.pse__Parent_Task__c = parentTask.ID;
                taskList.add(task);
            }
            
            System.debug('Parent task to be updated in total tasks : ' + taskList);
            update taskList;                                    
            
        } catch (Exception e) {
            Database.rollback(sp);
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, e.getLineNumber() + ' - ' + e.getMessage());
            ApexPages.addMessage(errorMessage);
        } 
    }   
    
}