ad_page_contract {

    Lists all the enabled surveys
    a user is eligable to complete.

    @author  philg@mit.edu
    @author  nstrug@arsdigita.com
    @creation-date    28th September 2000
    @cvs-id  $Id: index.tcl,v 1.6 2016/04/14 14:28:19 cvs Exp $
} {
    related_object_id:integer,optional
    related_context_id:integer,optional
    { return_url "" }
} -properties {
    surveys:multirow
}

set package_id [ad_conn package_id]
set context [list "Surveys"]
set user_id [auth::require_login]

db_multirow -extend {survey_url} surveys survey_select {
    select survey_id, name
    from survsimp_surveys, acs_objects
    where object_id = survey_id
    and context_id = :package_id
    and (acs_permission__permission_p(object_id, :user_id, 'survsimp_take_survey') = 't' OR acs_permission__permission_p(object_id, :user_id, 'read') = 't')
    and enabled_p = 't'
    order by upper(name)
} {
    set survey_url [export_vars -base "one" {survey_id related_object_id related_context_id return_url}]
}

db_release_unused_handles

ad_return_template

