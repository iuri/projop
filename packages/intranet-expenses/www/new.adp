<master>
<property name="doc(title)">@page_title;literal@</property>
<property name="context_bar">@context_bar;literal@</property>
<property name="main_navbar_label">expenses</property>
<!-- <property name="focus">@focus;literal@</property> -->

<h2>@page_title@</h2>

<if @message@ not nil>
  <div class="general-message">@message@</div>
</if>

<formtemplate id="@form_id@"></formtemplate>


