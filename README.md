# Multi Select Form Control for Preside

## Overview

This extension provides multi select form control with AJAX filtering functionality binding to Preside data objects.

## Installation

```
box install preside-ext-multiselect
```


## Ajax filtering setup

### Sample usage for form field xml definition

```xml
<field name="parent_field_name" control="multiSelect" object="parent_db_object" filterChildId="related_child_select_field_name" ajax="/formcontrols/MultiSelect/refreshChildOptions/" extraClass="select-filter-by"/>

<field name="related_child_select_field_name"  control="multiSelect" object="child_db_object" filterBy="db_field_link_to_parent" objectFilters="activeOnly" />
```

### Form attributes definition

| Attribute name  | Value  | Usage  |
|---|---|---|
| control  | multiSelect  |  |
| object  | Variable: DB object name |   |
| filterChildId  |   | Required for parent field. This could be a list of child field names  |
| ajax | /formcontrols/MultiSelect/refreshChildOptions/ | Ajax URL to post to |
| extraClass | select-filter-by | Required for parent field. |
| filterBy | Variable: FK within child DB object  | Required for child field. FK within the child DB object that links to the parent table |

## Ajax type-to-search setup

Useful for `select` with huge list of options to limit a fix number of result on load, and type-to-search to bring up further matching options.

### Sample usage for form field xml definition

```xml
<field name="field_with_long_options" control="multiSelect" ...  ajaxMaxRows="10" ajaxTextSearch="1" ajaxSearchCustomFilter="..." ajaxSearchUrl="..." />
```

### Form attributes definition

| Attribute name  | Value  | Usage  |
|---|---|---|
| control  | multiSelect  |  |
| ajaxMaxRows | /formcontrols/MultiSelect/refreshChildOptions/ | Max rows of options to be loaded (pre-selected values are not counted in this number) |
| ajaxTextSearch | 1 | Flag control to use Ajax text search |
| ajaxSearchCustomFilter | field_custom | Additional form control ID for type-to-search custom filtering (other than filterChildId / filterBy relationship). Could be a comma-separated list |
| ajaxSearchUrl | | Custom type-to-search post URL - to be used together with ajaxSearchCustomFilter. If not specified, the default value is /formcontrols/MultiSelect/getObjectRecordsForAjaxSelectControl/ |