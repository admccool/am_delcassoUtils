================================================================================

README for GIT REPO: am_delcassoUtils 

================================================================================

Utilities for Delcasso analysis 
Repo created: 1/9/13
README updated: 1/9/13

================================================================================

CONTENTS

================================================================================

reconcileEvents.m 
    - Reconciles Neuralynx timestamp events and raw output from Sebastien's
    processing GUI. Saves the output into the same directory from which the
    events files were originally loaded.
    
computeCC_allUnits.m
    - Computes a cross-correlogram for each unit in the recording session, and
    saves the result into a user-specified directory (currently, this is
    wherever the original data was loaded from).