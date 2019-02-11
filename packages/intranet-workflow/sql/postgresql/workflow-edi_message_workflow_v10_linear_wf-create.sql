
/*
 * Business Process Definition: EDI Message Workflow (edi_message_workflow_wf)
 *
 * Auto-generated by ACS Workflow Export, version 4.3
 *
 * Context: default
 */


/*
 * Cases table
 */
create table edi_message_workflow_wf_cases (
  case_id               integer primary key
                        references wf_cases on delete cascade
);

/* 
 * Declare the object type
 */


create function inline_0 () returns integer as '
begin
    PERFORM workflow__create_workflow (
        ''edi_message_workflow_wf'', 
        ''EDI Message Workflow'', 
        ''EDI Message Workflow'', 
        ''Standardized workflow for EDI message development'', 
        ''edi_message_workflow_wf_cases'',
        ''case_id''
    );

    return null;

end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();

        


/*****
 * Places
 *****/


    select workflow__add_place(
        'edi_message_workflow_wf',
        'start', 
        'Ready to Resource Assignment', 
        null
    );

        

    select workflow__add_place(
        'edi_message_workflow_wf',
        'before_business_analysis', 
        'Ready to Business Analysis', 
        null
    );

        

    select workflow__add_place(
        'edi_message_workflow_wf',
        'before_check_specs', 
        'Ready to Check Specs', 
        null
    );

        

    select workflow__add_place(
        'edi_message_workflow_wf',
        'before_develop_message', 
        'Ready to Develop Message', 
        null
    );

        

    select workflow__add_place(
        'edi_message_workflow_wf',
        'before_qc_check', 
        'Ready to QC Check', 
        null
    );

        

    select workflow__add_place(
        'edi_message_workflow_wf',
        'before_qa_solution_support', 
        'Ready to QA Solution Support', 
        null
    );

        

    select workflow__add_place(
        'edi_message_workflow_wf',
        'before_user_acceptance', 
        'Ready to User Acceptance', 
        null
    );

        

    select workflow__add_place(
        'edi_message_workflow_wf',
        'before_release_to_production', 
        'Ready to Release To Production', 
        null
    );

        

    select workflow__add_place(
        'edi_message_workflow_wf',
        'before_maintenance', 
        'Ready to Maintenance', 
        null
    );

        

    select workflow__add_place(
        'edi_message_workflow_wf',
        'before_user_satisfaction_survey', 
        'Ready to User Satisfaction Survey', 
        null
    );

        

    select workflow__add_place(
        'edi_message_workflow_wf',
        'end', 
        'Process finished', 
        null
    );

        
/*****
 * Roles
 *****/



	select workflow__add_role (
         'edi_message_workflow_wf',
         'resource_assignment',
         'Resource Assignment',
         1
    );

        

	select workflow__add_role (
         'edi_message_workflow_wf',
         'business_analysis',
         'Business Analysis',
         2
    );

        

	select workflow__add_role (
         'edi_message_workflow_wf',
         'check_specs',
         'Check Specs',
         3
    );

        

	select workflow__add_role (
         'edi_message_workflow_wf',
         'develop_message',
         'Develop Message',
         4
    );

        

	select workflow__add_role (
         'edi_message_workflow_wf',
         'qc_check',
         'QC Check',
         5
    );

        

	select workflow__add_role (
         'edi_message_workflow_wf',
         'qa_solution_support',
         'QA Solution Support',
         6
    );

        

	select workflow__add_role (
         'edi_message_workflow_wf',
         'user_acceptance',
         'User Acceptance',
         7
    );

        

	select workflow__add_role (
         'edi_message_workflow_wf',
         'release_to_production',
         'Release To Production',
         8
    );

        

	select workflow__add_role (
         'edi_message_workflow_wf',
         'maintenance',
         'Maintenance',
         9
    );

        

	select workflow__add_role (
         'edi_message_workflow_wf',
         'user_satisfaction_survey',
         'User Satisfaction Survey',
         10
    );

        

/*****
 * Transitions
 *****/



	select workflow__add_transition (
         'edi_message_workflow_wf',
         'resource_assignment',
         'Resource Assignment',
         'resource_assignment',
         1,
         'user'
	);
	
        

	select workflow__add_transition (
         'edi_message_workflow_wf',
         'business_analysis',
         'Business Analysis',
         'business_analysis',
         2,
         'user'
	);
	
        

	select workflow__add_transition (
         'edi_message_workflow_wf',
         'check_specs',
         'Check Specs',
         'check_specs',
         3,
         'user'
	);
	
        

	select workflow__add_transition (
         'edi_message_workflow_wf',
         'develop_message',
         'Develop Message',
         'develop_message',
         4,
         'user'
	);
	
        

	select workflow__add_transition (
         'edi_message_workflow_wf',
         'qc_check',
         'QC Check',
         'qc_check',
         5,
         'user'
	);
	
        

	select workflow__add_transition (
         'edi_message_workflow_wf',
         'qa_solution_support',
         'QA Solution Support',
         'qa_solution_support',
         6,
         'user'
	);
	
        

	select workflow__add_transition (
         'edi_message_workflow_wf',
         'user_acceptance',
         'User Acceptance',
         'user_acceptance',
         7,
         'user'
	);
	
        

	select workflow__add_transition (
         'edi_message_workflow_wf',
         'release_to_production',
         'Release To Production',
         'release_to_production',
         8,
         'user'
	);
	
        

	select workflow__add_transition (
         'edi_message_workflow_wf',
         'maintenance',
         'Maintenance',
         'maintenance',
         9,
         'user'
	);
	
        

	select workflow__add_transition (
         'edi_message_workflow_wf',
         'user_satisfaction_survey',
         'User Satisfaction Survey',
         'user_satisfaction_survey',
         10,
         'user'
	);
	
        

/*****
 * Arcs
 *****/



	select workflow__add_arc (
         'edi_message_workflow_wf',
         'business_analysis',
         'before_check_specs',
         'out',
         '',
         '',
         ''
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'business_analysis',
         'before_business_analysis',
         'in',
         '',
         '',
         ''
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'check_specs',
         'before_develop_message',
         'out',
         'wf_callback__guard_attribute_true',
         'check_specs_specs_ok_p',
         'Specs OK'
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'check_specs',
         'before_check_specs',
         'in',
         '',
         '',
         ''
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'check_specs',
         'before_business_analysis',
         'out',
         '#',
         '',
         'Not Specs OK'
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'develop_message',
         'before_develop_message',
         'in',
         '',
         '',
         ''
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'develop_message',
         'before_qc_check',
         'out',
         '',
         '',
         ''
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'maintenance',
         'before_user_satisfaction_survey',
         'out',
         'wf_callback__guard_attribute_true',
         'maintenance_maintenance_ok_p',
         'Maintenance OK'
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'maintenance',
         'before_maintenance',
         'in',
         '',
         '',
         ''
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'maintenance',
         'before_develop_message',
         'out',
         '#',
         '',
         'Not Maintenance OK'
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'qa_solution_support',
         'before_qa_solution_support',
         'in',
         '',
         '',
         ''
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'qa_solution_support',
         'before_develop_message',
         'out',
         '#',
         '',
         'Not QA OK'
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'qa_solution_support',
         'before_user_acceptance',
         'out',
         'wf_callback__guard_attribute_true',
         'qa_solution_support_qa_ok_p',
         'QA OK'
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'qc_check',
         'before_develop_message',
         'out',
         '#',
         '',
         'Not QC OK'
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'qc_check',
         'before_qa_solution_support',
         'out',
         'wf_callback__guard_attribute_true',
         'qc_check_qc_ok_p',
         'QC OK'
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'qc_check',
         'before_qc_check',
         'in',
         '',
         '',
         ''
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'release_to_production',
         'before_release_to_production',
         'in',
         '',
         '',
         ''
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'release_to_production',
         'before_maintenance',
         'out',
         'wf_callback__guard_attribute_true',
         'release_to_production_release_ok_p',
         'Release OK'
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'release_to_production',
         'before_develop_message',
         'out',
         '#',
         '',
         'Not Release OK'
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'resource_assignment',
         'start',
         'in',
         '',
         '',
         ''
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'resource_assignment',
         'before_business_analysis',
         'out',
         '',
         '',
         ''
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'user_acceptance',
         'before_release_to_production',
         'out',
         'wf_callback__guard_attribute_true',
         'user_acceptance_ua_ok_p',
         'UA OK'
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'user_acceptance',
         'before_develop_message',
         'out',
         '#',
         '',
         'Not UA OK'
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'user_acceptance',
         'before_user_acceptance',
         'in',
         '',
         '',
         ''
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'user_satisfaction_survey',
         'before_user_satisfaction_survey',
         'in',
         '',
         '',
         ''
	);

        

	select workflow__add_arc (
         'edi_message_workflow_wf',
         'user_satisfaction_survey',
         'end',
         'out',
         '',
         '',
         ''
	);

        

/*****
 * Attributes
 *****/



    select workflow__create_attribute(
        'edi_message_workflow_wf',
        'maintenance_maintenance_ok_p',
        'boolean',
        'Maintenance OK',
	null,
	null,
	null,
        't',
	1,
	1,
	null,
	'generic'
    );

        

	select workflow__add_trans_attribute_map(
        	'edi_message_workflow_wf', 
        	'maintenance',
        	'maintenance_maintenance_ok_p',
        	1
    );

        

    select workflow__create_attribute(
        'edi_message_workflow_wf',
        'release_to_production_release_ok_p',
        'boolean',
        'Release OK',
	null,
	null,
	null,
        't',
	1,
	1,
	null,
	'generic'
    );

        

	select workflow__add_trans_attribute_map(
        	'edi_message_workflow_wf', 
        	'release_to_production',
        	'release_to_production_release_ok_p',
        	1
    );

        

    select workflow__create_attribute(
        'edi_message_workflow_wf',
        'user_acceptance_ua_ok_p',
        'boolean',
        'UA OK',
	null,
	null,
	null,
        't',
	1,
	1,
	null,
	'generic'
    );

        

	select workflow__add_trans_attribute_map(
        	'edi_message_workflow_wf', 
        	'user_acceptance',
        	'user_acceptance_ua_ok_p',
        	1
    );

        

    select workflow__create_attribute(
        'edi_message_workflow_wf',
        'qa_solution_support_qa_ok_p',
        'boolean',
        'QA OK',
	null,
	null,
	null,
        't',
	1,
	1,
	null,
	'generic'
    );

        

	select workflow__add_trans_attribute_map(
        	'edi_message_workflow_wf', 
        	'qa_solution_support',
        	'qa_solution_support_qa_ok_p',
        	1
    );

        

    select workflow__create_attribute(
        'edi_message_workflow_wf',
        'qc_check_qc_ok_p',
        'boolean',
        'QC OK',
	null,
	null,
	null,
        't',
	1,
	1,
	null,
	'generic'
    );

        

	select workflow__add_trans_attribute_map(
        	'edi_message_workflow_wf', 
        	'qc_check',
        	'qc_check_qc_ok_p',
        	1
    );

        

    select workflow__create_attribute(
        'edi_message_workflow_wf',
        'check_specs_specs_ok_p',
        'boolean',
        'Specs OK',
	null,
	null,
	null,
        't',
	1,
	1,
	null,
	'generic'
    );

        

	select workflow__add_trans_attribute_map(
        	'edi_message_workflow_wf', 
        	'check_specs',
        	'check_specs_specs_ok_p',
        	1
    );

        
/*****
 * Transition-role-assignment-map
 *****/



    select workflow__add_trans_role_assign_map(
        'edi_message_workflow_wf',
        'resource_assignment',
        'maintenance'
    );

        

    select workflow__add_trans_role_assign_map(
        'edi_message_workflow_wf',
        'resource_assignment',
        'release_to_production'
    );

        

    select workflow__add_trans_role_assign_map(
        'edi_message_workflow_wf',
        'resource_assignment',
        'user_acceptance'
    );

        

    select workflow__add_trans_role_assign_map(
        'edi_message_workflow_wf',
        'resource_assignment',
        'qa_solution_support'
    );

        

    select workflow__add_trans_role_assign_map(
        'edi_message_workflow_wf',
        'resource_assignment',
        'qc_check'
    );

        

    select workflow__add_trans_role_assign_map(
        'edi_message_workflow_wf',
        'resource_assignment',
        'develop_message'
    );

        

    select workflow__add_trans_role_assign_map(
        'edi_message_workflow_wf',
        'resource_assignment',
        'check_specs'
    );

        

    select workflow__add_trans_role_assign_map(
        'edi_message_workflow_wf',
        'resource_assignment',
        'business_analysis'
    );

        

/*
 * Context/Transition info
 * (for context = default)
 */

insert into wf_context_transition_info
(context_key,
 workflow_key,
 transition_key,
 estimated_minutes,
 instructions,
 enable_callback,
 enable_custom_arg,
 fire_callback,
 fire_custom_arg,
 time_callback,
 time_custom_arg,
 deadline_callback,
 deadline_custom_arg,
 deadline_attribute_name,
 hold_timeout_callback,
 hold_timeout_custom_arg,
 notification_callback,
 notification_custom_arg,
 unassigned_callback,
 unassigned_custom_arg)
values
('default',
 'edi_message_workflow_wf',
 'resource_assignment',
 60,
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '');

insert into wf_context_transition_info
(context_key,
 workflow_key,
 transition_key,
 estimated_minutes,
 instructions,
 enable_callback,
 enable_custom_arg,
 fire_callback,
 fire_custom_arg,
 time_callback,
 time_custom_arg,
 deadline_callback,
 deadline_custom_arg,
 deadline_attribute_name,
 hold_timeout_callback,
 hold_timeout_custom_arg,
 notification_callback,
 notification_custom_arg,
 unassigned_callback,
 unassigned_custom_arg)
values
('default',
 'edi_message_workflow_wf',
 'business_analysis',
 500,
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '');

insert into wf_context_transition_info
(context_key,
 workflow_key,
 transition_key,
 estimated_minutes,
 instructions,
 enable_callback,
 enable_custom_arg,
 fire_callback,
 fire_custom_arg,
 time_callback,
 time_custom_arg,
 deadline_callback,
 deadline_custom_arg,
 deadline_attribute_name,
 hold_timeout_callback,
 hold_timeout_custom_arg,
 notification_callback,
 notification_custom_arg,
 unassigned_callback,
 unassigned_custom_arg)
values
('default',
 'edi_message_workflow_wf',
 'check_specs',
 120,
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '');

insert into wf_context_transition_info
(context_key,
 workflow_key,
 transition_key,
 estimated_minutes,
 instructions,
 enable_callback,
 enable_custom_arg,
 fire_callback,
 fire_custom_arg,
 time_callback,
 time_custom_arg,
 deadline_callback,
 deadline_custom_arg,
 deadline_attribute_name,
 hold_timeout_callback,
 hold_timeout_custom_arg,
 notification_callback,
 notification_custom_arg,
 unassigned_callback,
 unassigned_custom_arg)
values
('default',
 'edi_message_workflow_wf',
 'develop_message',
 2500,
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '');

insert into wf_context_transition_info
(context_key,
 workflow_key,
 transition_key,
 estimated_minutes,
 instructions,
 enable_callback,
 enable_custom_arg,
 fire_callback,
 fire_custom_arg,
 time_callback,
 time_custom_arg,
 deadline_callback,
 deadline_custom_arg,
 deadline_attribute_name,
 hold_timeout_callback,
 hold_timeout_custom_arg,
 notification_callback,
 notification_custom_arg,
 unassigned_callback,
 unassigned_custom_arg)
values
('default',
 'edi_message_workflow_wf',
 'qc_check',
 500,
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '');

insert into wf_context_transition_info
(context_key,
 workflow_key,
 transition_key,
 estimated_minutes,
 instructions,
 enable_callback,
 enable_custom_arg,
 fire_callback,
 fire_custom_arg,
 time_callback,
 time_custom_arg,
 deadline_callback,
 deadline_custom_arg,
 deadline_attribute_name,
 hold_timeout_callback,
 hold_timeout_custom_arg,
 notification_callback,
 notification_custom_arg,
 unassigned_callback,
 unassigned_custom_arg)
values
('default',
 'edi_message_workflow_wf',
 'qa_solution_support',
 500,
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '');

insert into wf_context_transition_info
(context_key,
 workflow_key,
 transition_key,
 estimated_minutes,
 instructions,
 enable_callback,
 enable_custom_arg,
 fire_callback,
 fire_custom_arg,
 time_callback,
 time_custom_arg,
 deadline_callback,
 deadline_custom_arg,
 deadline_attribute_name,
 hold_timeout_callback,
 hold_timeout_custom_arg,
 notification_callback,
 notification_custom_arg,
 unassigned_callback,
 unassigned_custom_arg)
values
('default',
 'edi_message_workflow_wf',
 'user_acceptance',
 5000,
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '');

insert into wf_context_transition_info
(context_key,
 workflow_key,
 transition_key,
 estimated_minutes,
 instructions,
 enable_callback,
 enable_custom_arg,
 fire_callback,
 fire_custom_arg,
 time_callback,
 time_custom_arg,
 deadline_callback,
 deadline_custom_arg,
 deadline_attribute_name,
 hold_timeout_callback,
 hold_timeout_custom_arg,
 notification_callback,
 notification_custom_arg,
 unassigned_callback,
 unassigned_custom_arg)
values
('default',
 'edi_message_workflow_wf',
 'release_to_production',
 500,
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '');

insert into wf_context_transition_info
(context_key,
 workflow_key,
 transition_key,
 estimated_minutes,
 instructions,
 enable_callback,
 enable_custom_arg,
 fire_callback,
 fire_custom_arg,
 time_callback,
 time_custom_arg,
 deadline_callback,
 deadline_custom_arg,
 deadline_attribute_name,
 hold_timeout_callback,
 hold_timeout_custom_arg,
 notification_callback,
 notification_custom_arg,
 unassigned_callback,
 unassigned_custom_arg)
values
('default',
 'edi_message_workflow_wf',
 'maintenance',
 15000,
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '');

insert into wf_context_transition_info
(context_key,
 workflow_key,
 transition_key,
 estimated_minutes,
 instructions,
 enable_callback,
 enable_custom_arg,
 fire_callback,
 fire_custom_arg,
 time_callback,
 time_custom_arg,
 deadline_callback,
 deadline_custom_arg,
 deadline_attribute_name,
 hold_timeout_callback,
 hold_timeout_custom_arg,
 notification_callback,
 notification_custom_arg,
 unassigned_callback,
 unassigned_custom_arg)
values
('default',
 'edi_message_workflow_wf',
 'user_satisfaction_survey',
 500,
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '');



/*
 * Context/Role info
 * (for context = default)
 */



/*
 * Context Task Panels
 * (for context = default)
 */


commit;
