
<property name="context">{/doc/acs-core-docs {Documentation}} {OpenACS Release Notes}</property>
<property name="doc(title)">OpenACS Release Notes</property>
<master>
<include src="/packages/acs-core-docs/lib/navheader"
		    leftLink="openacs-overview" leftLabel="Prev"
		    title="
Chapter 1. High level information: What is
OpenACS?"
		    rightLink="acs-admin" rightLabel="Next">
		<div class="sect1">
<div class="titlepage"><div><div><h2 class="title" style="clear: both">
<a name="release-notes" id="release-notes"></a>OpenACS Release Notes</h2></div></div></div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-9-0" id="release-notes-5-9-0"></a>Release 5.9.0</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>The release of OpenACS 5.9.0 contains the 78 packages of the
oacs-5-9 branch. These packages include the OpenACS core packages,
the major application packages (e.g. most the ones used on
OpenACS.org), and DotLRN 2.9.0.</p></li><li class="listitem">
<p>Summary of changes:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: circle;">
<li class="listitem">
<p>SQL:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: square;">
<li class="listitem"><p>Improved performance of acs-object deletion.</p></li><li class="listitem"><p>Replaced many manual referential integrity calls by built-in
handing in PostgreSQL.</p></li><li class="listitem"><p>Removed various manual bookkeeping and deletion operations in
the content repository by built-in handing in PostgreSQL.</p></li><li class="listitem"><p>Removed tree_sortkey on acs-objects to reduce its size and to
speedup operations, where the context-id is changed (could take on
large installation several minutes in earlier versions)</p></li><li class="listitem"><p>Removed several uncalled / redundant SQL statements and
functions.</p></li><li class="listitem">
<p>Cleanup of .xql files in acs-subsite:</p><div class="itemizedlist"><ul class="itemizedlist compact" style="list-style-type: opencircle;">
<li class="listitem" style="list-style-type: circle"><p>Some cleanup of .xql files: removed misleading sql-statements
from db_* calls, which were ignored due .xql files</p></li><li class="listitem" style="list-style-type: circle"><p>Removed bug where same query-name was used in different branches
of an if-statement for different sql statements, but the query-name
lead to the wrong result.</p></li><li class="listitem" style="list-style-type: circle"><p>Removed multiple entries of same query name from .xql files
(e.g. the entry "package_create_attribute_list.select_type_info"
was 7 (!) times in a single .xql file)</p></li>
</ul></div>
</li>
</ul></div>
</li><li class="listitem">
<p>Web Interface:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: square;">
<li class="listitem"><p>Improve Performance of WebSites created with OpenACS: e.g. move
core.js to a body requests, provide kernel parameter
ResourcesExpireInterval to specify expiration times for
resources.</p></li><li class="listitem"><p>Much better protection against XSS attacks.</p></li><li class="listitem"><p>Improved HTML validity (especially for admin pages)</p></li><li class="listitem">
<p>Improved admin interface:</p><div class="itemizedlist"><ul class="itemizedlist compact" style="list-style-type: opencircle;">
<li class="listitem" style="list-style-type: circle"><p>Placed all installation options to a single page.</p></li><li class="listitem" style="list-style-type: circle"><p>Added pagination to /admin/applications (was unusable for large
sites)</p></li><li class="listitem" style="list-style-type: circle"><p>New admin pages for subsites linked from site-wide-admin package
(/acs-admin).</p></li><li class="listitem" style="list-style-type: circle"><p>Added explanatory text to several admin pages.</p></li>
</ul></div>
</li><li class="listitem"><p>Add lightweight support for ckeditor4 for templating::richtext
widget (configurable via package parameter "RichTextEditor" of
acs-templating. ckeditor4 supports mobile devices (such as iPad,
...)</p></li>
</ul></div>
</li><li class="listitem">
<p>Templating:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: square;">
<li class="listitem"><p>Improved theme-ability: Moved more information into theme
packages in order to create responsive designs, reduce hard-coding
of paths, HTML etc.</p></li><li class="listitem"><p>Improved include-handling: All includes are now theme-able,
interfaces of includes can be defined with "ad_include_contract"
(similar to ad_page_contract).</p></li><li class="listitem"><p>Improved them-ability for display_templates. One can now provide
a display_template_name (similar to the sql statement name) to
refer to display templates. This enables reusability and is
theme-able.</p></li><li class="listitem"><p>Dimensional slider reform (ad_dimensional): Removed hard-coded
table layout from dimensional slider. Add backwards compatible
templates Move hard-coded styles into theme styling</p></li><li class="listitem"><p>Notification chunks are now theme-able as well (using
ad_include_contrat)</p></li><li class="listitem"><p>Complete template variable suffixes (adding noi18n, addressing
bug #2692, full list is now: noquote, noi18n, literal)</p></li><li class="listitem"><p>Added timeout and configurable secrets for signed url parameters
to export_vars/page_contracts. This can be used to secure sensitive
operations such as granting permissions since a link can be set to
timeout after e.g. 60 seconds; after that, the link is invalid. A
secret (password) can be set in section ns/server/$server/acs
parameter "parametersecret". For example, one can use now
"user_id:sign(max_age=60)" in export_vars to let the exported
variable expire after 60 seconds.</p></li>
</ul></div>
</li><li class="listitem">
<p>Misc:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: square;">
<li class="listitem"><p>Added ability to show ns_log statements of current request to
developer support output when developer support is activated
(controlled via package parameter "TclTraceLogServerities" in the
acs-tcl package parameters)</p></li><li class="listitem"><p>Added ability to save data sent by ns_return in files on the
file system. This can be used to validate HTML content also for
password protected pages (controlled via package parameter
"TclTraceSaveNsReturn" in the acs-tcl package parameters)</p></li><li class="listitem"><p>New api function "ad_log" having the same interface as ns_log,
but which logs the calling information (like URL and call-stack) to
ease tracking of errors.</p></li><li class="listitem"><p>Use per-thread caching to reduce number of mutex lock operations
and lock contention on various caches (util-memoize, xo_site_nodes,
xotcl_object_types) and nsvs (e.g ds_properties)</p></li><li class="listitem"><p>Improved templating of OpenACS core documentation</p></li><li class="listitem"><p>Improved Russian Internationalization</p></li><li class="listitem"><p>Make pretty-names of acs-core packages more consistent</p></li><li class="listitem"><p>Mark unused functions of acs-tcl/tcl/table-display-procs.tcl as
deprecated</p></li><li class="listitem"><p>Many more bug fixes (from bug tracker and extra) and performance
improvements.</p></li><li class="listitem">
<p>Version numbers:</p><div class="itemizedlist"><ul class="itemizedlist compact" style="list-style-type: opencircle;">
<li class="listitem" style="list-style-type: circle"><p>Require PG 9.0 (End Of Life of PostgreSQL 8.4 was July 2014)</p></li><li class="listitem" style="list-style-type: circle"><p>Require XOTcl 2.0 (presented at the Tcl conference in 2011).</p></li>
</ul></div>
</li>
</ul></div>
</li><li class="listitem">
<p>Changes in application packages:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: square;"><li class="listitem"><p>Various bug fixes and improvements for e.g. file-storage,
forums, news, notifications, xowiki.</p></li></ul></div>
</li>
</ul></div>
</li>
</ul></div><p>Altogether, OpenACS 5.9.0 differs from OpenACS 5.8.1 by the
following statistics</p><pre class="programlisting">
      3658 files changed, 120800 insertions(+), 97617 deletions(-)
  
</pre><p>contributed by 4 committers (Michael Aram, Victor Guerra, Gustaf
Neumann, Antonio Pisano) and patch/bugfix providers (Frank
Bergmann, Andrew Helsley, Felix MÃ¶dritscher, Marcos
Moser, Franz Penz, Thomas Renner). These are significantly more
changes as the differences in the last releases. All packages of
the release were tested with PostgreSQL 9.4.* and Tcl 8.5.*. For
more details, consult the <a class="ulink" href="" target="_top">raw ChangeLog</a>.</p>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-8-1" id="release-notes-5-8-1"></a>Release 5.8.1</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>The release contains the 78 packages of the oacs-5-8 branch.
These packages contain the OpenACS core packages, major application
packages (e.g. most the ones used on OpenACS.org), and DotLRN.</p></li><li class="listitem">
<p>All packages have the following properties:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: circle;">
<li class="listitem">
<p>SQL:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: square;">
<li class="listitem"><p>All packages are PostgreSQL 9.1+ compatible (tested with
PostgreSQL 9.3)</p></li><li class="listitem"><p>All SQL files with stored procedures use the recommended $$
quoting</p></li><li class="listitem"><p>All SQL-functions have regular function arguments instead of the
old-style aliases</p></li><li class="listitem"><p>The function_args() (query-able meta-data) are completed and
fixed</p></li><li class="listitem"><p>Incompatible functions (e.g. for sequences) are replaced.</p></li>
</ul></div>
</li><li class="listitem">
<p>Tcl:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: square;">
<li class="listitem"><p>All packages were brought up Tcl 8.5, including the actual Tcl
idioms where appropriate (e.g. using the safer expand operator,
range indices, dict, lassign, etc.)</p></li><li class="listitem"><p>The code was updated to prefer byte-compiled functions instead
of legacy functions from ancient Tcl versions.</p></li><li class="listitem"><p>The code works with NaviServer and AOLserver.</p></li>
</ul></div>
</li><li class="listitem">
<p>API:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: square;">
<li class="listitem"><p>All packages are free from calls to deprecated code (157
functions are marked as deprecated and will be moved into an
"outdated" package in the 5.9 or 6.0 release)</p></li><li class="listitem"><p>General overhaul of package management</p></li><li class="listitem"><p>Install-from-local and install-from-repository can be used to
install the provided packages based on a acs-core installation.
This means that also DotLRN can be installed from repository or
from local into an existing OpenACS instance.</p></li><li class="listitem"><p>Install-from-repository offers filtering functions, allows to
install optionally from head-channel (for packages not in the base
channel of the installed instance). Install-from-repository works
more like an app-store, showing as well vendor information</p></li><li class="listitem"><p>Packages can be equipped with xml-based configuration files
(e.g. changing parameters for style packages)</p></li><li class="listitem"><p>Package developers can upload .apm packages via workflow for
review by core members and for inclusion to the repository. The
option is integrated with package management, the link is offered
for local packages. We hope to attract additional vendors
(universities, companies) to make their packages available on this
path.</p></li><li class="listitem"><p>New management-functions for package instances (list, create,
delete package instances)</p></li><li class="listitem">
<p>Substantially improved API browser:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>Show just relevant parts of .xql files for a function</p></li><li class="listitem"><p>Provide syntax-highlighting for www scripts as well</p></li><li class="listitem"><p>Handle more special cases like e.g. util_memoize</p></li><li class="listitem"><p>Provide links to Tcl functions depending on the installed Tcl
version</p></li><li class="listitem"><p>Provide links to NaviServer or OpenACS functions depending on
installed version</p></li><li class="listitem"><p>Syntax highlighter uses CSS rather than hard-coded markup</p></li><li class="listitem"><p>Significant performance improvement for large installations</p></li>
</ul></div>
</li>
</ul></div>
</li>
</ul></div>
</li>
</ul></div><p>Altogether, OpenACS 5.8.1 differs from OpenACS 5.8.0 in about
100,000 modifications (6145 commits) contributed by 5
committers.</p>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-8-0" id="release-notes-5-8-0"></a>Release 5.8.0</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>Compatibility with PostgreSQL 9.2: The new version installs
without any need for special parameter settings in new PostgreSQL
versions. This makes it easier to use e.g. shared or packaged
PostgreSQL installations.</p></li><li class="listitem"><p>Compatibility with NaviServer 4.99.5 or newer</p></li><li class="listitem"><p>Performance and scalability improvements</p></li><li class="listitem"><p>Various bug fixes</p></li>
</ul></div><p>Altogether, OpenACS 5.8.0 differs from OpenACS 5.7.0 in more
than 18.000 modifications (781 commits) contributed by 7
committers.</p>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-7-0" id="release-notes-5-7-0"></a>Release 5.7.0</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;"><li class="listitem"><p>Made changes that extend acs-kernel's create_type and
create_attribute procs, so they're optionally able to create sql
tables and columns. Optional metadata params allow for the
automatic generation of foreign key references, check exprs,
etc.</p></li></ul></div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-6-0" id="release-notes-5-6-0"></a>Release 5.6.0</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;"><li class="listitem">
<p>Added new package dependency type, "embeds". This is a variant
of the "extends" package dependency type added in OpenACS 5.5.0. It
allows one to write embeddable packages, with scripts made visible
in client packages using URLs which include the embedded package's
package key. An example embeddable package might be a rewritten
"attachments" package. The current implementation requires a global
instance be mounted, and client packages generate urls to that
global instance. Among other things, this leads to the user
navigating to the top-level subsite, losing any subsite theming
that might be associated with a community. Using "embeds", a
rewritten package would run in the client package's context,
maintaining theming and automatically associating attachments with
the client package.</p><p>Added global package parameters - parameters can now have scope
"local" or "global", with "local" being the default..</p><p>Fixes for ns_proxy handling</p><p>Significant speedup for large sites</p><p>Optional support for selenium remote control
(acs-automated-tests)</p><p>New administration UI to manage mime types and extension map</p><p>Added acs-mail-lite package params for rollout support</p><p>Support for 3-chars language codes in acs-lang</p><p>Added OOXML mime types in acs-content-repository</p>
</li></ul></div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-5-0" id="release-notes-5-5-0"></a>Release 5.5.0</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;"><li class="listitem">
<p>PostgreSQL 8.3 is now fully supported, including the use of the
built-in standard version of tsearch2.</p><p>TinyMCE has been upgraded to 3.2.4.1 with language pack
support.</p><p>acs-mail-lite now correctly implements rollout support.</p><p>Added new package dependency type, "extends". Implements a weak
form of package inheritance (parameters and, optionally,
templates). Multiple inheritance is supported. For instance, the
non-core "layout-managed-subsite" extends the "acs-subsite" and
"layout-manager" packages, resulting in a package that combines the
semantics of both.</p><p>Added new package attribute "implements-subsite-p" (default
"f"). If true, this package may be mounted as a subsite and is
expected to implement subsite semantics. Typically used by packages
which extend acs-subsite.</p><p>Added new package attribute "inherit-templates-p" (default "t").
If true, the package inherits templates defined in the packages it
extends. This means that the package only needs to specify
templates where the UI of an extended package is modified or
extended. This greatly reduces the need to fork base packages when
one needs to customize it. Rather than modify the package directly,
use "extends" rather than "requires" then rewrite those templates
you need to customize.</p><p>Added a simple mechanism for defining subsite themes, removing
the hard-wired choices implemented in earlier versions of OpenACS.
The default theme has been moved into a new package,
"openacs-default-theme". Simplifies the customization of the look
and feel of OpenACS sites and subsites.</p><p>The install xml facility has been enhanced to allow the calling
of arbitrary Tcl procedures and includes various other enhancements
written by Xarg. Packages can extend the facility, too. As an
example of what can be done, the configuration of .LRN communities
could be moved from a set of interacting parameters to a cleaner
XML description of how to build classes and clubs, etc.</p><p>Notifications now calls lang::util::localize on the message
subject and body before sending the message out, using the
recipient locale if set, the site-wide one if not. This will cause
message keys (entered as <span style="color: red">&lt;span&gt;#&lt;/span&gt;</span>....# strings) to be
replaced with the language text for the chosen locale.</p>
</li></ul></div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-4-2" id="release-notes-5-4-2"></a>Release 5.4.2</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;"><li class="listitem">
<p>This is a minor bugfix release.</p><p>Site node caching was removed as doesn't work correctly</p><p>Critical issues with search on oracle were fixed</p><p>More html strict work etc</p>
</li></ul></div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-4-1" id="release-notes-5-4-1"></a>Release 5.4.1</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;"><li class="listitem"><p>This is a minor bugfix release.</p></li></ul></div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-4-0" id="release-notes-5-4-0"></a>Release 5.4.0</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;"><li class="listitem">
<p>New Templating API added to add scripts, css, etc to the HTML
HEAD and BODY sections of the generated HTML document. Please see
/packages/acs-templating/tcl/head-procs.tcl or visit the
template::head procs in the API browser for details.</p><p>Templates have been modified to comply with HTML strict</p><p>The Search package's results page has been improved</p><p>TinyMCE WYSIWYG support has been added, RTE and HTMLArea support
dropped</p><p>acs-mail-lite's send has been cleaned up to properly encode
content, to handle file attachments, etc. "complex-send" will
disappear from acs-core in a future release.</p>
</li></ul></div>
</div><p>The ChangeLogs include an annotated list of changes (<a class="xref" href="">???</a>) since the last release and in the entire
5.7 release sequence <a class="xref" href="">???</a>.</p><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-3-1" id="release-notes-5-3-1"></a>Release 5.3.1</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;"><li class="listitem">
<p>Bug fixes.</p><p>New TIPs implemented.</p><p>All Core Automated Tests for Postgres pass.</p><p>New Site and Blank master templates and CSS compatible with the
.LRN Zen work. Compatibility master templates are provided for
existing sites.</p>
</li></ul></div>
</div><p>The ChangeLogs include an annotated list of changes (<a class="xref" href="">???</a>) since the last release and in the entire
5.7 release sequence <a class="xref" href="">???</a>.</p><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-3-0" id="release-notes-5-3-0"></a>Release 5.3.0</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;"><li class="listitem">
<p>Bug fixes.</p><p>New TIPs implemented.</p><p>All Core Automated Tests for Postgres pass.</p>
</li></ul></div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-2-0" id="release-notes-5-2-0"></a>Release 5.2.0</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;"><li class="listitem">
<p>Bug fixes.</p><p>New TIPs implemented.</p><p>This release does <span class="strong"><strong>not</strong></span> include new translations.</p>
</li></ul></div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-1-4" id="release-notes-5-1-4"></a>Release 5.1.4</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;"><li class="listitem">
<p>Bug fixes.</p><p>The missing CR Tcl API has been filled in, thanks to Rocael and
his team and Dave Bauer.</p><p>This release does <span class="strong"><strong>not</strong></span> include new translations.</p>
</li></ul></div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-1-3" id="release-notes-5-1-3"></a>Release 5.1.3</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;"><li class="listitem"><p>Bug fixes, primarily for .LRN compatibility in support of
upcoming .LRN 2.1.0 releases. This release does <span class="strong"><strong>not</strong></span> include new translations since
5.1.2.</p></li></ul></div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-1-2" id="release-notes-5-1-2"></a>Release 5.1.2</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>Translations syncronized with the translation server. Basque and
Catalan added.</p></li><li class="listitem"><p>For a complete change list, see the Change list since 5.1.0 in
<a class="xref" href="">???</a>.</p></li>
</ul></div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-1-1" id="release-notes-5-1-1"></a>Release 5.1.1</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>This is the first release using the newest adjustment to the
versioning convention. The OpenACS 5.1.1 tag will apply to OpenACS
core as well as to the most recent released version of every
package, including .LRN.</p></li><li class="listitem"><p>Translations syncronized with the translation server.</p></li><li class="listitem"><p>
<a class="ulink" href="http://openacs.org/bugtracker/openacs/com/acs-lang/bug?bug%5fnumber=1519" target="_top">Bug 1519</a> fixed. This involved renaming all
catalog files for ch_ZH, TH_TH, AR_EG, AR_LB, ms_my, RO_RO, FA_IR,
and HR_HR. If you work with any of those locales, you should do a
full catalog export and then import (via <a class="ulink" href="/acs-lang/admin" target="_top">/acs-lang/admin</a>) after
upgrading acs-lang. (And, of course, make a backup of both the
files and database before upgrading.)</p></li><li class="listitem"><p>Other bug fixes since 5.1.0: <a class="ulink" href="http://openacs.org/bugtracker/openacs/bug?bug_number=1785" target="_top">1785</a>, <a class="ulink" href="http://openacs.org/bugtracker/openacs/bug?bug_number=1793" target="_top">1793</a>, and over a dozen additional bug fixes.</p></li><li class="listitem"><p>For a complete change list, see the Change list since 5.0.0 in
<a class="xref" href="">???</a>.</p></li>
</ul></div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-1-0" id="release-notes-5-1-0"></a>Release 5.1.0</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>Lots of little tweaks and fixes</p></li><li class="listitem"><p>Complete Change list since 5.0.0 in Changelog</p></li><li class="listitem"><p><a class="ulink" href="http://openacs.org/bugtracker/openacs/core?filter%2efix%5ffor%5fversion=125273&amp;filter%2estatus=closed" target="_top">Many Bug fixes</a></p></li>
</ul></div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-0-4" id="release-notes-5-0-4"></a>Release 5.0.4</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;"><li class="listitem"><p>New translations, including for .LRN 2.0.2.</p></li></ul></div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-0-3" id="release-notes-5-0-3"></a>Release 5.0.3</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;"><li class="listitem"><p>Bug fixes: <a class="ulink" href="http://openacs.org/bugtracker/openacs/bug?bug%5fnumber=1560" target="_top">1560</a>, <a class="ulink" href="http://openacs.org/bugtracker/openacs/bug?bug%5fnumber=1556" target="_top">#1556. Site becomes unresponsive, requires
restart</a>
</p></li></ul></div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-0-2" id="release-notes-5-0-2"></a>Release 5.0.2</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>Bug fixes: <a class="ulink" href="http://openacs.org/bugtracker/openacs/bug?bug%5fnumber=1495" target="_top">#1495. Croatian enabled by default</a>, <a class="ulink" href="http://openacs.org/bugtracker/openacs/bug?bug%5fnumber=1496" target="_top">#1496. APM automated install fails if files have
spaces in their names</a>, <a class="ulink" href="http://openacs.org/bugtracker/openacs/bug?bug%5fnumber=1494" target="_top">#1494. automated upgrade crashes (halting the upgrade
process)</a>
</p></li><li class="listitem"><p>Complete Change list since 5.0.0 in Changelog</p></li><li class="listitem"><p>File tagging scheme in CVS changed to follow <a class="ulink" href="http://openacs.org/forums/message-view?message_id=161375" target="_top">TIP #46: (Approved) Rules for Version Numbering and
CVS tagging of Packages</a>
</p></li>
</ul></div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-0-1" id="release-notes-5-0-1"></a>Release 5.0.1</h3></div></div></div><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>All work on the translation server from 7 Nov 2003 to 7 Feb 2004
is now included in catalogs.</p></li><li class="listitem"><p>One new function in acs-tcl, util::age_pretty</p></li><li class="listitem"><p>Complete Change list since 5.0.0 in Changelog</p></li><li class="listitem"><p>Many documentation updates and doc bug fixes</p></li>
</ul></div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="release-notes-5-0-0" id="release-notes-5-0-0"></a>Release 5.0.0</h3></div></div></div><p>This is OpenACS 5.0.0. This version contains no known security,
data loss, or crashing bugs, nor any bugs judged release blockers.
This version has received manual testing. It has passed current
automated testing, which is not comprehensive. This release
contains work done on the translation server
http://translate.openacs.org through 7 Nov 2003.</p><p>Please report bugs using our <a class="ulink" href="http://openacs.org/bugtracker/openacs/" target="_top">Bug
Tracker</a> at the <a class="ulink" href="http://openacs.org/" target="_top">OpenACS website</a>.</p><p>You may want to begin by reading our installation documentation
for <a class="xref" href="unix-installation" title="a Unix-like system">the section called &ldquo;a
Unix-like system&rdquo;</a>. Note that the Windows
documentation is not current for OpenACS 5.7.0, but an alternative
is to use John Sequeira's <a class="ulink" href="http://www.pobox.com/~johnseq/projects/oasisvm/" target="_top">Oasis VM project</a>.</p><p>After installation, the full documentation set can be found by
visiting <code class="filename">http://yourserver/doc</code>.</p><p>New features in this release:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>Internationalization support. A message catalog to store
translated text, localization of dates, number formatting, timezone
conversion, etc. Allows you to serve your users in their
language.</p></li><li class="listitem"><p>External authenticaiton. Integrate with outside user databases
through e.g. LDAP, RADIUS, Kerberos, MS Active Directory. Imports
user information through IMS Enterprise 1.1 format. Easily extended
to support other authentication, password management, account
creation, and account import mechanisms. This includes improvements
to the basic cookie handling, so logins can be expired without the
user's identity being completely lost. You can set login to expire
after a certain period (e.g. 8 hours, then password must be
refreshed), or you can have all issues login cookies expired at
once, e.g. if you have left a permanent login cookie on a public
machine somewhere.</p></li><li class="listitem"><p>User interface enhancements. All pages, including site-wide and
subsite admin pages, will be templated, so they can be styled using
master template and site-wide stylesheets. We have a new
default-master template, which includes links to administration,
your workspace, and login/logout, and is rendered using CSS. And
there's a new community template
(/packages/acs-subsite/www/group-master), which provides useful
navigation to the applications and administrative UI in a subsite.
In addition, there's new, simpler UI for managing members of a
subsite, instantiating and mounting applications, setting
permissions, parameters, etc. Site-wide admin as also seen the
addition of a new simpler software install UI to replace the APM
for non-developer users, and improved access to parameters,
internationalization, automated testing, service contracts, etc.
The list builder has been added for easily generating templated
tables and lists, with features such as filtering, sorting, actions
on multiple rows with checkboxes, etc. Most of all, it's fast to
use, and results in consistently-looking, consistently-behaving,
templated tables.</p></li><li class="listitem"><p>Automated testing. The automated testing framework has been
improved significantly, and there are automated tests for a number
of packages.</p></li><li class="listitem"><p>Security enhancements. HTML quoting now happens in the
templating system, greatly minimizing the chance that users can
sneak malicious HTML into the pages of other users.</p></li><li class="listitem"><p>Oracle 9i support.</p></li><li class="listitem"><p>Who's online feature.</p></li><li class="listitem"><p>Spell checking.</p></li>
</ul></div><p>Potential incompatibilities:</p><div class="itemizedlist"><ul class="itemizedlist" style="list-style-type: disc;">
<li class="listitem"><p>With the release of OpenACS 5, PostgreSQL 7.2 is no longer
supported. Upgrades are supported from OpenACS 4.6.3 under Oracle
or PostgreSQL 7.3.</p></li><li class="listitem"><p>The undocumented special handling of ~ and +variable+ in
formtemplates, found in <code class="filename">packages/acs-templating/resources/*</code>, has been
removed in favor of using &lt;noparse&gt; and \\@variable\\@ (the
standard templating mechanisms). Locally provided formtemplate
styles still using these mechanisms will break.</p></li><li class="listitem"><p>Serving backup files and files from the CVS directories is
turned off by default via the acs-kernel parameter ExcludedFiles in
section request-processor (The variable provides a string match
glob list of files and is defaulted to "*/CVS/* *~")</p></li>
</ul></div><div class="cvstag">($&zwnj;Id: release-notes.xml,v 1.30.2.5 2015/12/01
11:17:58 gustafn Exp $)</div>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="idp140400233855216" id="idp140400233855216"></a>Release 4.6.3</h3></div></div></div><p><a class="ulink" href="release-notes-4-6-3" target="_top">Release Notes for 4.6.3</a></p>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="idp140400233856720" id="idp140400233856720"></a>Release 4.6.2</h3></div></div></div><p><a class="ulink" href="release-notes-4-6-2" target="_top">Release Notes for 4.6.2</a></p>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="idp140400233858224" id="idp140400233858224"></a>Release 4.6</h3></div></div></div><p><a class="ulink" href="release-notes-4-6" target="_top">Release Notes for 4.6</a></p>
</div><div class="sect2">
<div class="titlepage"><div><div><h3 class="title">
<a name="idp140400233859728" id="idp140400233859728"></a>Release 4.5</h3></div></div></div><p><a class="ulink" href="release-notes-4-5" target="_top">Release Notes for 4.5</a></p>
</div>
</div>
<include src="/packages/acs-core-docs/lib/navfooter"
		    leftLink="openacs-overview" leftLabel="Prev" leftTitle="Overview"
		    rightLink="acs-admin" rightLabel="Next" rightTitle="
Part II. Administrator's Guide"
		    homeLink="index" homeLabel="Home" 
		    upLink="general-documents" upLabel="Up"> 
		