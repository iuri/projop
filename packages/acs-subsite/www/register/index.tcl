ad_page_contract {
    Prompt the user for email and password.
    @cvs-id $Id: index.tcl,v 1.6 2015/12/04 13:50:10 cvs Exp $
} {
    {authority_id:naturalnum ""}
    {username ""}
    {email ""}
    {return_url ""}
}

set subsite_id [ad_conn subsite_id]
set login_template [parameter::get -parameter "LoginTemplate" -package_id $subsite_id]

if {$login_template eq ""} {
    set login_template "/packages/acs-subsite/lib/login"
}


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
