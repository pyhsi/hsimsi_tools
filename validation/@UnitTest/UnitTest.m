classdef UnitTest < handle
    % Class to handle ISETBIO unit tests
    
    % Public properties
    properties
        
    end
    
    properties (SetAccess = private) 
        % a collection of various system information
        systemData = struct();

        % validation results for current probe
        validationFailedFlag = true;
        validationData       = struct();
        validationReport     = 'None';
        
        % cell array with data for all examined probes
        allProbeData = {};
    end
    
    % Public methods
    methods
        % Constructor
        function obj = UnitTest(validationScriptFileName)
            obj.systemData.vScriptFileName = sprintf('%s',validationScriptFileName);
            obj.systemData.vScriptListing  = fileread([validationScriptFileName '.m']);
            obj.systemData.datePerformed   = datestr(now);
            obj.systemData.matlabVersion   = version;
            obj.systemData.computer        = computer;
            obj.systemData.gitRepoBranch   = obj.retrieveGitBranch();
        end
        
        % Method to add and execute a new probe
        addProbe(obj, varargin);
         
        % Method to print the validation report
        printReport(obj);
    
        % Method to store the validatation results
        storeValidationResults(obj, varargin); ...

        % Method that returns info for all probes run
        [sectionNames, functionNames] = getProbesInfo(obj);
    
        % Method to save probes info to a file. pushToGit reads this file.
        saveProbesInfo(obj);
    end
    
    methods (Access = private)    
        % Method to retrieve the git branch string
        gitBranchString = retrieveGitBranch(obj);
    end
    
    methods (Static)
        updateParentUnitTestObject(validationReport, validationFailedFlag, validationDataToSave, runParams);
    end
    
end