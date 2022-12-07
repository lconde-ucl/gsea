
nextflow.enable.dsl = 2



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PARAMETERS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Check inputfile exists


// This actually cannot happen as there is a default inputfile in nextflow.config
if( !params.inputfile ){
    exit 1, "No inputfile specified! Specify path with --inputfile."
}

inputfile = file(params.inputfile)
if( !inputfile.exists() ) exit 1, "Inputfile not found: ${params.inputfile}. Specify path with --inputfile."

file_ch = Channel.fromPath( params.inputfile, checkIfExists: true )

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { GSEA } from './modules/local/gsea'


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    HELP 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def helpMessage() {
    log.info """
          Usage:
          The typical command for running the pipeline is as follows:
          gsea --inputfile inputfile.rnk [--outdir results ...] 

          Arguments:
           --inputfile FILENAME         Text file with two columns: gene IDs and metric [./inputfile.rnk]
           --outdir DIRNAME             Output director [./results]
           --gmx FILENAME               File with gene sets in GMX format. If not specified, it will use the hallmark gene sets from MSigDB (HUGO names)
           --min_set NUM                Ignore gene sets that contain less than NUM genes [15]"
           --max_set NUM	        Ignore gene sets that contain more than NUM genes [500]"
           --perm NUM                   Number of permutations [1000]"
           --help                       This usage statement

          Other useful nextflow arguments:
           -resume                        Execute the script using the cached results, useful to continue executions that was stopped by an error [False]
           -with-tower                    Monitor workflow execution with Seqera Tower service [False]
           -ansi-log                      Enable/disable ANSI console logging [True]
           -N, -with-notification         Send a notification email on workflow completion to the specified recipients [False]

          Example inputfile.rnk:
		LAPTM5  212.497428485785
		DOCK8   200.881877490159
		SLCO2B1 200.30461847802
		[...]
		VCL     -85.2788529062547
		ZDHHC16 -95.3839532411221
		TPM1    -103.69585047931
           """
}

if (params.help){
    helpMessage()
    exit 0
}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    HEADER
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


// Header 
println "========================================================"
println "       N E X T F L O W   G S E A   P I P E L I N E      "
println "========================================================"
println "['Pipeline Name']     = nf/gsea"
println "['Pipeline Version']  = $workflow.manifest.version"
println "['Inputfile']         = $params.inputfile"
println "['Outdir']            = $params.outdir"
println "['Working dir']       = $workflow.workDir"
println "['Current user']      = $USER"
println "========================================================"



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow{ 
    GSEA(file_ch) 
} 


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {                
    println "Pipeline completed at: $workflow.complete"
    println "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
}


workflow.onError = {
    println "Oops... Pipeline execution stopped with the following message: ${workflow.errorMessage}"
}
