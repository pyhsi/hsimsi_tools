function validateAll()  
    
    % Initialize a @UnitTest object to handle the results
    unitTestOBJ = UnitTest(mfilename('fullpath'));
    
    % Set optional parameters.
    %
    % 1. Amount of information to be outputted in command window.
    % If set to false,  only failed validation runs produce output.
    % If set to true, info regarding all validation runs will be displayed.
    % Defaults to false
    unitTestOBJ.displayAllValidationResults = false;
    
    % 2. Whether to append the validation results to the history of (local) 
    % validation runs. Defaults to false.
    unitTestOBJ.addResultsToValidationResultsHistory = true;
    
    % 3. Whether to append the validation results to the history of ground 
    % truth data sets. Defaults to false.
    unitTestOBJ.addResultsToGroundTruthHistory = true;
    
    % 4. Whether to push results to github upon a sucessful validation outcome. 
    % Defaults to true;
    unitTestOBJ.pushToGitHubOnSuccessfulValidation = false;
    
    % 5. Whether @UnitTest will ask the user which ground truth data set to 
    % use in case there are more than one in the history of saved ground truth 
    % data sets. If set to false, the last ground truth data set will be used.
    unitTestOBJ.queryUserIfMoreThanOneGroundTruthDataSetsExist = true;
    
    % 6. Set numeric tolerance below which two numeric values are to be
    % considered equal. Defaults to 100*eps. IN practice, we have
    % found that computations on different (MAC) machines may differ by up to 400*eps.
    unitTestOBJ.numericTolerance = 500*eps;
    
    % 7. Minimum level at which feedback messages will be emitted to the user 
    % via the command window.
    % For minimum output set this to UnitTest.MAXIMUM_IMPORTANCE
    % For maximum output set this to UnitTest.MININUM_IMPORTANCE
    % For itermediate output set this to UnitTest.MEDIUM_IMPORTANCE
    unitTestOBJ.messageEmissionStrategy = UnitTest.MEDIUM_IMPORTANCE; 
    
    % 8. Locations of directories where ISETBIO gh-Pages and wiki are cloned
    % Defaults are '/Users/Shared/Matlab/Toolboxes/ISETBIO_GhPages/isetbio'
    % and '/Users/Shared/Matlab/Toolboxes/ISETBIO_Wiki/isetbio.wiki'
    % These locations can be overriden here:
    % unitTestOBJ.ISETBIO_gh_pages_CloneDir = ...
    % unitTestOBJ.ISETBIO_wikiCloneDir = ...
    
    % 9. Location where svn is installed
    % unitTestOBJ.SVN_BIN_DIRECTORY = '/usr/bin/svn';
    
    % Parameters that can be set separately (if need be) for each probe.
    % If you want execution to continue on error use the following setting:
    onErrorReaction = 'CatchExemption'; 

    % Specify how to react if an excemption is raised
    % If you want execution to stop on error (so you can fix it) use:
    onErrorReaction = 'RethrowExemption';
    
    % Flag indicating whether the published report will include the MATLAB 
    % code that was run
    showCodeInPublishedReport = true;
    
    % Flag indicating whether to generate plots when running validation scripts.
    generatePlots = false;
    
    % Add probes here. One probe per validation script.
    unitTestOBJ.addProbe(...
        'name', 'comparison of PTB- vs. ISETBIO-computed irradiance', ...   % name to identify this probe
        'functionSectionName', '1. PTB vs. ISETBIO validations', ...        % section to which validation script belong to
        'functionName',   'PTB_vs_ISETBIO_Irradiance', ...                  % name of the validation script
        'functionParams',  struct(), ...                                    % struct with validation script input arguments
        'onErrorReaction', onErrorReaction, ...                             % how to react on errors in the validation script. 
        'showTheCode',     showCodeInPublishedReport, ...                   % whether to include the MATLAB code to the report                           
        'generatePlots',   generatePlots ...                                % whether to generate MATLAB plots
    );
    
    unitTestOBJ.addProbe(...
        'name', 'comparison of PTB- vs. ISETBIO-computed colorimetry', ...  
        'functionSectionName', '1. PTB vs. ISETBIO validations', ...        
        'functionName',   'PTB_vs_ISETBIO_Colorimetry', ...                 
        'functionParams',  struct(), ...                                    
        'onErrorReaction', onErrorReaction, ...                              
        'showTheCode',     showCodeInPublishedReport, ...                    
        'generatePlots',   generatePlots ...
    );

    unitTestOBJ.addProbe(...
        'name','validation of human retinal illuminance at 580 nm',...       
        'functionSectionName', '2. Human eye computation validations', ...   
        'functionName',   'validateHumanRetinalIlluminance580nm', ...        
        'functionParams',  struct(), ...                                     
        'onErrorReaction', onErrorReaction, ...                              
        'showTheCode',     showCodeInPublishedReport, ...                    
        'generatePlots',   generatePlots ...
    );

    unitTestOBJ.addProbe(...
        'name', 'validation of human PTF vs pupil size', ...                
        'functionSectionName', '2. Human eye computation validations', ...   
        'functionName',   'validateOTFandPupilSize', ...                    
        'functionParams',  struct(), ...                                     
        'onErrorReaction', onErrorReaction, ...                              
        'showTheCode',     showCodeInPublishedReport, ...                   
        'generatePlots',   generatePlots ...
    );

    unitTestOBJ.addProbe(...
        'name', 'scene re-illumination validation', ...                      
        'functionSectionName', '3. Scene set/get operation validations',...  
        'functionName',   'validateSceneReIllumination', ...                 
        'functionParams',  struct(), ...                                     
        'onErrorReaction', onErrorReaction, ...                              
        'showTheCode',     showCodeInPublishedReport, ...                    
        'generatePlots',   generatePlots ...
    );

    unitTestOBJ.addProbe(...
        'name', 'diffuser validation', ...                                   
        'functionSectionName', '4. Optical Image validations', ...           
        'functionName',   'validateDiffuser', ...                           
        'functionParams',  struct(), ...                                     
        'onErrorReaction', onErrorReaction, ...                              
        'showTheCode',     showCodeInPublishedReport, ...                    
        'generatePlots',   generatePlots ...
    );
   
    unitTestOBJ.addProbe(...
        'name', 'validation skeleton', ...                                   
        'functionSectionName', 'z. Skeleton validation scripts', ...         
        'functionName',   'validateSkeleton', ...                            
        'functionParams',  struct(), ...                                     
        'onErrorReaction', onErrorReaction, ...                              
        'showTheCode',     showCodeInPublishedReport, ...                   
        'generatePlots',   generatePlots ...
    );

    % Contrast validation run data to ground truth data set
    unitTestOBJ.contrastValidationRunDataToGroundTruth(); 
end





