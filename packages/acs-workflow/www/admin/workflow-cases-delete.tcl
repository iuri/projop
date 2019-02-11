ad_page_contract { 
    Delete a workflow definition from the system.

    @author Lars Pind (lars@pinds.com)
    @creation-date 28 September 2000
    @cvs-id $Id: workflow-cases-delete.tcl,v 1.2 2015/11/19 20:18:57 cvs Exp $
} {
    workflow_key:notnull
    {return_url "workflow?[export_vars -url { workflow_key}]"}
} -validate {
    workflow_exists -requires {workflow_key} {
	if ![db_string workflow_exists "
	select 1 from wf_workflows 
	where workflow_key = :workflow_key"] {
	    ad_complain "You seem to have specified a nonexistent workflow."
	}
    }
}



db_exec_plsql delete_cases {
    begin 
        workflow.delete_cases(workflow_key => :workflow_key);
    end;
}

ad_returnredirect $return_url
