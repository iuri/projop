# /packages/intranet-reporting-finance/www/finance-payment-balance.tcl
#
# Copyright (C) 2003 - 2009 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/ for licensing details.


ad_page_contract {
	testing reports	
    @param start_year Year to start the report
    @param start_unit Month or week to start within the start_year
} {
    { start_date "" }
    { end_date "" }
    { level_of_detail 2 }
    { output_format "html" }
    project_id:integer,optional
    customer_id:integer,optional
}

# ------------------------------------------------------------
# Security

# Label: Provides the security context for this report
# because it identifies unquely the report's Menu and
# its permissions.
set menu_label "reporting-finance-payment-balance"
set current_user_id [ad_maybe_redirect_for_registration]

set read_p [db_string report_perms "
	select	im_object_permission_p(m.menu_id, :current_user_id, 'read')
	from	im_menus m
	where	m.label = :menu_label
" -default 'f']

if {![string equal "t" $read_p]} {
    ad_return_complaint 1 "<li>
[lang::message::lookup "" intranet-reporting.You_dont_have_permissions "You don't have the necessary permissions to view this page"]"
    return
}


# ------------------------------------------------------------
# Parameter Checking

# Check that Start & End-Date have correct format
if {"" != $start_date && ![regexp {^[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]$} $start_date]} {
    ad_return_complaint 1 "Start Date doesn't have the right format.<br>
    Current value: '$start_date'<br>
    Expected format: 'YYYY-MM-DD'"
}

if {"" != $end_date && ![regexp {^[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]$} $end_date]} {
    ad_return_complaint 1 "End Date doesn't have the right format.<br>
    Current value: '$end_date'<br>
    Expected format: 'YYYY-MM-DD'"
}


# ------------------------------------------------------------
# Page Settings

set page_title "Payments"
set context_bar [im_context_bar $page_title]
set context ""

set help_text "
<strong>$page_title:</strong><br>

The purpose of this report is to show the actual payments that have
entered and left the company in the give time period.
<br>

The report list all payments in the given period and identifies the
related financial documents and projects.
"


# ------------------------------------------------------------
# Defaults

set rowclass(0) "roweven"
set rowclass(1) "rowodd"

set days_in_past 7

set default_currency [im_parameter -package_id [im_package_cost_id] "DefaultCurrency" "" "EUR"]
set cur_format [im_l10n_sql_currency_format]
set date_format [im_l10n_sql_date_format]

db_1row todays_date "
select
	to_char(sysdate::date - :days_in_past::integer, 'YYYY') as todays_year,
	to_char(sysdate::date - :days_in_past::integer, 'MM') as todays_month,
	to_char(sysdate::date - :days_in_past::integer, 'DD') as todays_day
from dual
"

if {"" == $start_date} { 
    set start_date "$todays_year-$todays_month-01"
}

# Maxlevel is 4. Normalize in order to show the right drop-down element
if {$level_of_detail > 3} { set level_of_detail 3 }


db_1row end_date "
select
	to_char(to_date(:start_date, 'YYYY-MM-DD') + 31::integer, 'YYYY') as end_year,
	to_char(to_date(:start_date, 'YYYY-MM-DD') + 31::integer, 'MM') as end_month,
	to_char(to_date(:start_date, 'YYYY-MM-DD') + 31::integer, 'DD') as end_day
from dual
"

if {"" == $end_date} { 
    set end_date "$end_year-$end_month-01"
}


set company_url "/intranet/companies/view?company_id="
set project_url "/intranet/projects/view?project_id="
set invoice_url "/intranet-invoices/view?invoice_id="
set user_url "/intranet/users/view?user_id="
set this_url [export_vars -base "/intranet-reporting-finance/finance-payment-balance" {start_date end_date} ]


# ------------------------------------------------------------
# Conditional SQL Where-Clause
#

set criteria [list]

if {[info exists customer_id]} {
    lappend criteria "pcust.company_id = :customer_id"
}

# Select project & subprojects
if {[info exists project_id]} {
    lappend criteria "p.project_id in (
	select
		p.project_id
	from
		im_projects p,
		im_projects parent_p
	where
		parent_p.project_id = :project_id
		and p.tree_sortkey between parent_p.tree_sortkey and tree_right(parent_p.tree_sortkey)
		and p.project_status_id not in ([im_project_status_deleted])
    )"
}

set where_clause [join $criteria " and\n	    "]
if { ![empty_string_p $where_clause] } {
    set where_clause " and $where_clause"
}


# ------------------------------------------------------------
# Define the report - SQL, counters, headers and footers 
#


set inner_sql "
select
	p.received_date as paid_date,
	p.note as paid_note,
	p.amount as paid_amount,
	p.currency as paid_currency,
	c.cost_id,
	c.cost_type_id,
	c.cost_status_id,
	c.cost_nr,
	c.cost_name,
	c.effective_date,
	c.customer_id,
	c.provider_id,
	c.amount as cost_amount,
	c.currency as cost_currency,
	round((c.amount *
	  im_exchange_rate(c.effective_date::date, c.currency, 'EUR')) :: numeric
	  , 2) as cost_amount_converted,
	round((p.amount *
	  im_exchange_rate(p.received_date::date, p.currency, 'EUR')) :: numeric
	  , 2) as paid_amount_converted,
	r.object_id_one as project_id
from
	im_payments p
	LEFT OUTER JOIN im_costs c on (p.cost_id = c.cost_id)
	LEFT OUTER JOIN acs_rels r on (c.cost_id = r.object_id_two)
where
	c.cost_type_id in (3700, 3702, 3704, 3706)
	and c.effective_date >= to_date(:start_date, 'YYYY-MM-DD')
	and c.effective_date < to_date(:end_date, 'YYYY-MM-DD')
"


set sql "
select
	c.*,
	to_char(c.effective_date, :date_format) as effective_date_formatted,
	to_char(c.effective_date, 'YYMM')::integer * customer_id as effective_month,
	cust.company_path as customer_nr,
	cust.company_name as customer_name,
	prov.company_path as provider_nr,
	prov.company_name as provider_name,
	CASE WHEN c.cost_type_id = 3700 THEN c.paid_amount_converted END as paid_invoice_amount,
	CASE WHEN c.cost_type_id = 3702 THEN c.paid_amount_converted END as paid_quote_amount,
	CASE WHEN c.cost_type_id = 3704 THEN c.paid_amount_converted END as paid_bill_amount,
	CASE WHEN c.cost_type_id = 3706 THEN c.paid_amount_converted END as paid_po_amount,

	CASE WHEN c.cost_type_id = 3700 THEN to_char(c.paid_amount, :cur_format) || ' ' || c.paid_currency 
	END as paid_invoice_amount_pretty,
	CASE WHEN c.cost_type_id = 3702 THEN to_char(c.paid_amount, :cur_format) || ' ' || c.paid_currency 
	END as paid_quote_amount_pretty,
	CASE WHEN c.cost_type_id = 3704 THEN to_char(c.paid_amount, :cur_format) || ' ' || c.paid_currency 
	END as paid_bill_amount_pretty,
	CASE WHEN c.cost_type_id = 3706 THEN to_char(c.paid_amount, :cur_format) || ' ' || c.paid_currency 
	END as paid_po_amount_pretty,
	to_char(c.paid_amount, :cur_format) || ' ' || c.paid_currency as paid_amount_pretty,
	p.project_name,
	p.project_nr,
	pcust.company_id as project_customer_id,
	pcust.company_name as project_customer_name
from
	($inner_sql) c
	LEFT OUTER JOIN im_projects p on (c.project_id = p.project_id)
	LEFT OUTER JOIN im_companies cust on (c.customer_id = cust.company_id)
	LEFT OUTER JOIN im_companies prov on (c.provider_id = prov.company_id)
	LEFT OUTER JOIN im_companies pcust on (p.company_id = pcust.company_id)
where
	1 = 1
	$where_clause
order by
	customer_id,
	p.project_name
"


set report_def [list \
    group_by project_customer_id \
    header {
	"\#colspan=10 <a href=$this_url&customer_id=$project_customer_id&level_of_detail=4 
	target=_blank><img src=/intranet/images/plus_9.gif width=9 height=9 border=0></a> 
	<b><a href=$company_url$project_customer_id>$project_customer_name</a></b>"
    } \
	content [list \
	    group_by project_id \
	    header { } \
	    content [list \
		    header {
			""
			""
			"<nobr>$cost_amount $cost_currency</nobr>"
			"<nobr>$effective_date_formatted</nobr>"
			"<a href=$invoice_url$cost_id>$cost_name</a>"
			"<nobr>$paid_invoice_amount_pretty</nobr>"
			"<nobr>$paid_quote_amount_pretty</nobr>"
			"<nobr>$paid_bill_amount_pretty</nobr>"
			"<nobr>$paid_po_amount_pretty</nobr>"
			$paid_note
		    } \
		    content {} \
	    ] \
	    footer {
		"" 
		"<a href=$this_url&project_id=$project_id&level_of_detail=4 
		target=_blank><img src=/intranet/images/plus_9.gif width=9 height=9 border=0></a> 
		<b><a href=$project_url$project_id>$project_name</a></b>"
		"" 
		"" 
		""
		"<i>$invoice_subtotal $default_currency</i>" 
		"<i>$quote_subtotal $default_currency</i>" 
		"<i>$bill_subtotal $default_currency</i>" 
		"<i>$po_subtotal $default_currency</i>"
		""
	    } \
    ] \
    footer {  } \
]

set invoice_total 0
set quote_total 0
set bill_total 0
set po_total 0

# Global header/footer
set header0 {"Cust" "Project" "Document<br>Amount<br>(w/o VAT)" "Effective<br>Date" "Document<br>Name" "Payment Invoice" "Payment Quote" "Payment Bill" "Payment PO" "Note"}
set footer0 {
	"" 
	"" 
	"" 
	"" 
	"<br><b>Total:</b>" 
	"<br><b>$invoice_total $default_currency</b>" 
	"<br><b>$quote_total $default_currency</b>" 
	"<br><b>$bill_total $default_currency</b>" 
	"<br><b>$po_total $default_currency</b>"
	""
}

#
# Subtotal Counters (per project)
#
set invoice_subtotal_counter [list \
	pretty_name "Invoice Amount" \
	var invoice_subtotal \
	reset \$project_id \
	expr "\$paid_invoice_amount+0" \
]

set quote_subtotal_counter [list \
	pretty_name "Quote Amount" \
	var quote_subtotal \
	reset \$project_id \
	expr "\$paid_quote_amount+0" \
]

set bill_subtotal_counter [list \
	pretty_name "Bill Amount" \
	var bill_subtotal \
	reset \$project_id \
	expr "\$paid_bill_amount+0" \
]

set po_subtotal_counter [list \
	pretty_name "Po Amount" \
	var po_subtotal \
	reset \$project_id \
	expr "\$paid_po_amount+0" \
]

#
# Grand Total Counters
#
set invoice_grand_total_counter [list \
	pretty_name "Invoice Amount" \
	var invoice_total \
	reset 0 \
	expr "\$paid_invoice_amount+0" \
]

set quote_grand_total_counter [list \
	pretty_name "Quote Amount" \
	var quote_total \
	reset 0 \
	expr "\$paid_quote_amount+0" \
]

set bill_grand_total_counter [list \
	pretty_name "Bill Amount" \
	var bill_total \
	reset 0 \
	expr "\$paid_bill_amount+0" \
]

set po_grand_total_counter [list \
	pretty_name "Po Amount" \
	var po_total \
	reset 0 \
	expr "\$paid_po_amount+0" \
]




set counters [list \
	$invoice_subtotal_counter \
	$quote_subtotal_counter \
	$bill_subtotal_counter \
	$po_subtotal_counter \
	$invoice_grand_total_counter \
	$quote_grand_total_counter \
	$bill_grand_total_counter \
	$po_grand_total_counter \
]


# ------------------------------------------------------------
# Constants
#

set start_years {2010 2010 2011 2011 2012 2012 2013 2013 2014 2014 2015 2015 2016 2016 2017 2017}
set start_months {01 Jan 02 Feb 03 Mar 04 Apr 05 May 06 Jun 07 Jul 08 Aug 09 Sep 10 Oct 11 Nov 12 Dec}
set start_weeks {01 1 02 2 03 3 04 4 05 5 06 6 07 7 08 8 09 9 10 10 11 11 12 12 13 13 14 14 15 15 16 16 17 17 18 18 19 19 20 20 21 21 22 22 23 23 24 24 25 25 26 26 27 27 28 28 29 29 30 30 31 31 32 32 33 33 34 34 35 35 36 36 37 37 38 38 39 39 40 40 41 41 42 42 43 43 44 44 45 45 46 46 47 47 48 48 49 49 50 50 51 51 52 52}
set start_days {01 1 02 2 03 3 04 4 05 5 06 6 07 7 08 8 09 9 10 10 11 11 12 12 13 13 14 14 15 15 16 16 17 17 18 18 19 19 20 20 21 21 22 22 23 23 24 24 25 25 26 26 27 27 28 28 29 29 30 30 31 31}
set levels {1 "Customer Only" 2 "Customer+Project" 3 "All Details"} 

# ------------------------------------------------------------
# Start formatting the page
#

# Write out HTTP header, considering CSV/MS-Excel formatting
im_report_write_http_headers -output_format $output_format

# Add the HTML select box to the head of the page
switch $output_format {
    html {
	ns_write "
	[im_header]
	[im_navbar]
	<table cellspacing=0 cellpadding=0 border=0>
	<tr valign=top>
	<td>
	<form>
		<table border=0 cellspacing=1 cellpadding=1>
		<tr>
		  <td class=form-label>Level of Details</td>
		  <td class=form-widget>
		    [im_select -translate_p 0 level_of_detail $levels $level_of_detail]
		  </td>
		</tr>
		<tr>
		  <td class=form-label>Start Date</td>
		  <td class=form-widget>
		    <input type=textfield name=start_date value=$start_date>
		  </td>
		</tr>
		<tr>
		  <td class=form-label>End Date</td>
		  <td class=form-widget>
		    <input type=textfield name=end_date value=$end_date>
		  </td>
		</tr>
                <tr>
                  <td class=form-label>Format</td>
                  <td class=form-widget>
                    [im_report_output_format_select output_format "" $output_format]
                  </td>
                </tr>
		<tr>
		  <td></td>
		  <td><input type=submit value=Submit></td>
		</tr>
		</table>
		</form>
	</td>
	<td>
		<table cellspacing=2 width=90%>
		<tr><td>$help_text</td></tr>
		</table>
	</td>
	</tr>
	</table>
	<table border=0 cellspacing=1 cellpadding=1>\n"
    }
}	
im_report_render_row \
    -output_format $output_format \
    -row $header0 \
    -row_class "rowtitle" \
    -cell_class "rowtitle"


set footer_array_list [list]
set last_value_list [list]
set class "rowodd"

ns_log Notice "intranet-reporting-finance/finance-payment-balance: sql=\n$sql"

db_foreach sql $sql {
  
	if { "" == $project_id || "" == $project_name } {
	    set project_id 0
	    set help_txt [lang::message::lookup "" intranet-reporting.ProjectDeleted "The project might have been removed from the system"]
	    set project_name "[lang::message::lookup "" intranet-reporting.No_project "Undefined Project"] [im_gif -translate_p 0 help $help_txt]"
	}

	if {"" == $customer_id} {
	    set customer_id 0
	    set help_txt [lang::message::lookup "" intranet-reporting.CustomerDeleted "The customer might have been removed from the system"]
	    set project_customer_name "[lang::message::lookup "" intranet-reporting.NoCustomer "Undefined Customer"] [im_gif -translate_p 0 help $help_txt]"
	}

	im_report_display_footer \
	    -output_format $output_format \
	    -group_def $report_def \
	    -footer_array_list $footer_array_list \
	    -last_value_array_list $last_value_list \
	    -level_of_detail $level_of_detail \
	    -row_class $class \
	    -cell_class $class
	
	im_report_update_counters -counters $counters
	
	set last_value_list [im_report_render_header \
	    -output_format $output_format \
	    -group_def $report_def \
	    -last_value_array_list $last_value_list \
	    -level_of_detail $level_of_detail \
	    -row_class $class \
	    -cell_class $class
	]

	set footer_array_list [im_report_render_footer \
	    -output_format $output_format \
	    -group_def $report_def \
	    -last_value_array_list $last_value_list \
	    -level_of_detail $level_of_detail \
	    -row_class $class \
	    -cell_class $class
	]
}

im_report_display_footer \
    -output_format $output_format \
    -group_def $report_def \
    -footer_array_list $footer_array_list \
    -last_value_array_list $last_value_list \
    -level_of_detail $level_of_detail \
    -display_all_footers_p 1 \
    -row_class $class \
    -cell_class $class

im_report_render_row \
    -output_format $output_format \
    -row $footer0 \
    -row_class $class \
    -cell_class $class \
    -upvar_level 1


switch $output_format {
    ns_write "</table>\n[im_footer]\n"
}
