ad_page_contract {
  @cvs-id $Id: bind.tcl,v 1.5 2015/12/04 13:50:14 cvs Exp $
} {
  user_id:naturalnum,notnull
} -properties {
  users:onerow
}



set query "select 
             first_name, last_name
           from
             ad_template_sample_users
           where user_id = :user_id"

db_1row users_query $query -column_array users

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
