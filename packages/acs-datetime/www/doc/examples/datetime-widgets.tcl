# /packages/acs-datetime/www/doc/examples/datetime-widgets.tcl

ad_page_contract {

    Examples of the basic dt_ widgets

    @author  ron@arsdigita.com
    @creation-date 2000/12/01
    @cvs-id  $Id: datetime-widgets.tcl,v 1.4 2015/12/04 13:50:01 cvs Exp $
} -properties {
    dt_examples:multirow
}

set title "Date and Time Widgets"
set context [list [list . "ACS DateTime Examples"] $title]

set example_list {
    "dt_widget_datetime -default now name"
    "dt_widget_datetime -show_date 0 -use_am_pm 1 name halves"
    "dt_widget_datetime -show_date 0 -default now name halves"
    ""
    "dt_widget_datetime -show_date 0 name seconds"
    "dt_widget_datetime -show_date 0 name minutes"
    "dt_widget_datetime -show_date 0 name fives"
    "dt_widget_datetime -show_date 0 name quarters"
    "dt_widget_datetime -show_date 0 name halves"
    "dt_widget_datetime -show_date 0 name hours"
    "dt_widget_datetime -show_date 0 -use_am_pm 1 name hours"
    ""
    "dt_widget_datetime name days"
    "dt_widget_datetime name months"
    
}

# Generate a multirow datasource to transmit the examples to the
# template.  Then we just loop over the examples list to generate all
# of the display information.

multirow create dt_examples "procedure" "result"

foreach example $example_list {
    multirow append dt_examples $example [{*}$example]
}


ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
