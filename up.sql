create or replace
algorithm = UNDEFINED view `view_saleregisterreport` as
select
    distinct date_format(cast(`s`.`date` as date), '%d/%m/%Y') as `date`,
    date_format(cast(`s`.`date` as date), '%M - %Y') as `entrymonth`,
    `s`.`invoice_no` as `invoice_no`,
    ifnull(`s`.`reference_no`, '-') as `reference_no`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `s`.`ledger_id`)) as `ledger_name`,
    ifnull(`a`.`addr_l1`, '-') as `address1`,
    ifnull(`c`.`city_name`, '-') as `city_name`,
    ifnull(`st`.`state_name`, '-') as `party_state_name`,
    ifnull(`l`.`tan_no`, '-') as `tan_no`,
    ifnull(`l`.`sale_tax_no`, '-') as `sale_tax_no`,
    ifnull(`b`.`pan_no`, '-') as `pan_no`,
    ifnull(`i`.`i_des`, `s2i`.`i_des`) as `i_des`,
    ifnull(`i`.`unit`, `s2i`.`unit`) as `unit`,
    `convert_qty_to_upper_unit`(sum(`s3`.`quantity`),
    ifnull(`i`.`i_code`, `s2i`.`i_code`)) as `quantity`,
    round(`s3`.`quantity`, 2) as `weight`,
    round(`get_rate`(`s3`.`rate`, ifnull(`i`.`i_code`, `s2i`.`i_code`), `s3`.`unit_of_rate`), 2) as `rate`,
    round(((`s3`.`quantity` * `s3`.`rate`) - (((`s3`.`quantity` * `s3`.`rate`) * `s3`.`discount`) / 100)), 2) as `prod_value`,
    ifnull(`s3`.`vat_amount`, 0) as `vat_amount`,
    `s3`.`cst_amount` as `cst_amount`,
    `s3`.`cgst_amt` as `cgst_amt`,
    `s3`.`sgst_amt` as `sgst_amt`,
    `s3`.`igst_amt` as `igst_amt`,
    `s3`.`total_cost` as `total_cost`,
    `s`.`reference_id` as `reference_id`,
    `s`.`total_amt` as `bill_amt`,
    `s`.`ledger_id` as `ledger_id`,
    ifnull(`vc`.`voucher_name`, `v`.`voucher_name`) as `voucher_name`,
    `s`.`module_id` as `module_id`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `s`.`sale_ledger_id`)) as `CR_ledger_name`,
    ifnull((select `ledgerdetails`.`gstin_no` from `ledgerdetails` where ((`ledgerdetails`.`ledger_id` = `s`.`ledger_id`) and (`ledgerdetails`.`gst_registration_date` <= `s`.`date`))), '') as `Party_gstin_no`,
    ifnull(`i`.`hsn_code`, `s2i`.`hsn_code`) as `hsn_code`,
    '' as `tracking_no`,
    ifnull(`s`.`ewaybill_no`, '-') as `ewaybill_no`,
    ifnull(`s`.`narration`, ' ') as `narration`,
    `s3`.`discount` as `discount`,
    `s`.`deduction` as `deduction`,
    `br`.`br_name` as `br_name`,
    `br`.`gstin_no` as `branch_gstin_no`,
    `brstate`.`state_name` as `branch_state_name`,
    ifnull(`slo`.`reference_id`,(select `slo`.`reference_id` from `salesorder` where (`salesorder`.`order_no` = `dn1`.`order_no`))) as `order_no`,
    ifnull(`s`.`delivery_type`, '') as `delivery_type`,
    ifnull(`s`.`halting_charges`, '') as `halting_charges`,
    ifnull(`s`.`other_charges`, '') as `other_charges`,
    ifnull(`s`.`loading_charges`, '') as `loading_charges`,
    ifnull((select `tr`.`amt` from `accounttransaction` `tr` where ((`tr`.`tr_id` = `s`.`fc_tr_id`) and (`tr`.`acc_type` = 'DR'))), 0) as `freight_charges`,
    ifnull(`d`.`dri_name`, '') as `dri_name`,
    ifnull(`d`.`veh_no`, '') as `veh_no`,
    ifnull(`d`.`contact1`, '') as `contact_no`,
    ifnull((select `ledgerdetails`.`comp_name` from `ledgerdetails` where (`ledgerdetails`.`ledger_id` = `d`.`transport_ledger_id`)), '') as `transport_name`,
    `s`.`tot_tcs_amt` as `tot_tcs_amt`,
    ifnull(`s`.`irn_no`, '') as `irn_no`,
    ifnull((select sum(`tr`.`disc_amount`) from ((`salediscountledger` `tr` join `accountcreation` `ac` on((`ac`.`ledger_id` = `tr`.`ledger_id`))) join `groupcreation` `g` on((`g`.`group_id` = `ac`.`group_id`))) where (`tr`.`invoice_no` = `s`.`invoice_no`)), 0) as `ledger_erning_deduction`,
    (
    select
        distinct `br`.`br_name`
    from
        (`mastertransaction` `m`
    join `branch` `br` on
        ((`br`.`br_id` = `m`.`br_id`)))
    where
        (`m`.`reference_no` = `s`.`invoice_no`)) as `acc_branch`,
    `s3`.`trans_id3` as `trans_id3`,
    ifnull(`l`.`contact1`, '') as `cust_contactNo`,
    concat(ifnull(`l`.`fname`, ''), ' ', ifnull(`l`.`mname`, ''), ' ', ifnull(`l`.`lname`, '')) as `res_person_name`,
    ifnull((select `itemgroups`.`grp_nm` from `itemgroups` where (`itemgroups`.`grp_code` = ifnull(`i`.`grp_code`, `s2i`.`grp_code`))), '') as `item_group_nm`,
    ifnull((select `category`.`category` from `category` where (`category`.`category_id` = ifnull(`i`.`category`, `s2i`.`category`))), '') as `item_category`,
    ifnull(ifnull(`i`.`product_identity`, `s2i`.`product_identity`), '') as `item_type`,
    (((`s3`.`quantity` * `s3`.`rate`) * `s3`.`discount`) / 100) as `discount_amt`,
    `g`.`group_name` as `group_name`,
    ifnull((select `at`.`area_name` from `areastatic` `at` where (`at`.`area_code` = `l`.`area_code`)), '-') as `area_name`,
    ifnull(`cd`.`consignee_name`, '') as `consignee`,
    ifnull(`cd`.`contact_no`, '') as `consignee_contact_no`,
    ifnull(`cd`.`address`, '') as `consignee_addr`,
    ifnull(`ac`.`party_code`, '') as `party_code`,
    ifnull((select concat(`employee`.`fname`, ' ', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `l`.`emp_id`)), '-') as `emp_name`,
    ifnull((select concat(`employee`.`fname`, '', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `s`.`last_modified_by`)), '-') as `last_modified_by`,
    (
    select
        `projectmodules`.`module_name`
    from
        `projectmodules`
    where
        (`projectmodules`.`module_id` = `s`.`module_id`)) as `module_name`,
    ((`s3`.`cgst_percent` + `s3`.`sgst_percent`) + `s3`.`igst_percent`) as `gst_rate`,
    ifnull(`u`.`govt_unit`, '') as `govt_unit`,
    `s`.`is_reverse_charge` as `is_reverse_charge`,
    ifnull(`s`.`sale_scheme_remark`, '') as `sale_scheme_remark`,
    ifnull(`s`.`broker_id`, '') as `broker_id`,
    ifnull((select `accountcreation`.`ledger_name` from `accountcreation` where (`accountcreation`.`ledger_id` = `s`.`broker_id`)), '') as `broker_name`,
    ifnull((select `att`.`amt` from `accounttransaction` `att` where ((`att`.`tr_id` = `s`.`feed_distribution_jv`) and (`att`.`acc_type` = 'CR'))), 0) as `feed_distribution_amt`
from
    ((((((((((((((((((((((((((`sale` `s`
join `accountcreation` `ac` on
    ((`ac`.`ledger_id` = `s`.`ledger_id`)))
join `groupcreation` `g` on
    ((`g`.`group_id` = `ac`.`group_id`)))
left join `transaddrdetails` `traddr` on
    ((`traddr`.`tradd_id` = `s`.`transid`)))
left join `consigneedetails` `cd` on
    ((`cd`.`consignee_id` = `traddr`.`consignee_id`)))
join `vouchercreation` `v` on
    ((`v`.`voucher_id` = `s`.`voucher_id`)))
left join `vouchercreation` `vc` on
    ((`vc`.`voucher_id` = `v`.`voucher_type`)))
join `salestransactions1` `s1` on
    ((`s1`.`invoice_no` = `s`.`invoice_no`)))
join `salestransactions2` `s2` on
    ((`s2`.`trans_id1` = `s1`.`trans_id1`)))
join `salestransactions3` `s3` on
    ((`s3`.`trans_id2` = `s2`.`trans_id2`)))
left join `stockout` `so` on
    ((`so`.`out_id` = `s3`.`out_id`)))
left join `stockin` `si` on
    ((`si`.`stock_id` = `so`.`stock_id`)))
left join `stockdetails` `sd` on
    ((`sd`.`stock_detail_id` = `si`.`stock_detail_id`)))
left join `items` `i` on
    ((`i`.`i_code` = `sd`.`item_id`)))
left join `items` `s2i` on
    ((`s2i`.`i_code` = `s2`.`item_id`)))
left join `ledgerdetails` `l` on
    ((`l`.`ledger_id` = `s`.`ledger_id`)))
left join `address` `a` on
    ((`a`.`addr_id` = `l`.`addr_id`)))
left join `city` `c` on
    ((`c`.`city_id` = `a`.`city_id`)))
left join `state` `st` on
    ((`st`.`state_id` = `a`.`state_id`)))
left join `bankdetails` `b` on
    ((`b`.`bank_id` = `l`.`bank_id`)))
join `branch` `br` on
    ((`br`.`br_id` = `s`.`branch_id`)))
join `address` `braddr` on
    ((`braddr`.`addr_id` = `br`.`addr_id`)))
join `state` `brstate` on
    ((`brstate`.`state_id` = `braddr`.`state_id`)))
left join `units` `u` on
    ((`s2i`.`unit` = `u`.`short_name`)))
left join `salesorder` `slo` on
    ((`slo`.`order_no` = `s1`.`order_no`)))
left join `deliverynotetransact1` `dn1` on
    ((`dn1`.`tracking_no` = `s1`.`tracking_no`)))
left join `drivertransportrecord` `d` on
    ((`d`.`trans_id` = `s`.`transport`)))
where
    ((not(exists(
    select
        `newfarmer`.`ledger_id`
    from
        `newfarmer`
    where
        (`newfarmer`.`ledger_id` = `s`.`ledger_id`))))
        and (`s`.`date` between '2023-01-01' and '2024-12-31')
            and (`s`.`module_id` = 1))
group by
    `s3`.`trans_id3`
union
select
    distinct date_format(cast(`cs`.`date` as date), '%d/%m/%Y') as `date`,
    date_format(cast(`cs`.`date` as date), '%M - %Y') as `entrymonth`,
    `cs`.`cs_id` as `invoice_no`,
    ifnull(`cs`.`dc_number`, '-') as `reference_no`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `cs`.`trader_id`)) as `ledger_name`,
    ifnull(`a`.`addr_l1`, '-') as `address1`,
    ifnull(`c`.`city_name`, '-') as `city_name`,
    ifnull(`st`.`state_name`, '-') as `party_state_name`,
    ifnull(`l`.`tan_no`, '-') as `tan_no`,
    ifnull(`l`.`sale_tax_no`, '-') as `sale_tax_no`,
    ifnull(`b`.`pan_no`, '-') as `pan_no`,
    ifnull(`stockitems`.`i_des`, `i`.`i_des`) as `i_des`,
    ifnull(`stockitems`.`unit`, `i`.`unit`) as `unit`,
    `cs`.`tot_b_sold` as `quantity`,
    round(`cs`.`total_wt`, 2) as `weight`,
    `cs`.`rate` as `rate`,
    `cs`.`amt` as `prod_value`,
    0 as `vat_amount`,
    0 as `cst_amount`,
    0 as `cgst_amt`,
    0 as `sgst_amt`,
    0 as `igst_amt`,
    `cs`.`amt` as `total_cost`,
    `cs`.`reference_id` as `reference_id`,
    `cs`.`net_amt` as `bill_amt`,
    `cs`.`trader_id` as `ledger_id`,
    ifnull(`vc`.`voucher_name`, `v`.`voucher_name`) as `voucher_name`,
    `m`.`module_id` as `module_id`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `cs`.`sale_ledger_id`)) as `CR_ledger_name`,
    ifnull((select `ledgerdetails`.`gstin_no` from `ledgerdetails` where ((`ledgerdetails`.`ledger_id` = `cs`.`trader_id`) and (`ledgerdetails`.`gst_registration_date` <= `cs`.`date`))), '') as `Party_gstin_no`,
    ifnull(`stockitems`.`hsn_code`, `i`.`hsn_code`) as `hsn_code`,
    '' as `tracking_no`,
    '' as `ewaybill_no`,
    ifnull(`mt`.`narration`, '') as `narration`,
    0 as `discount`,
    0 as `deduction`,
    `br`.`br_name` as `br_name`,
    `br`.`gstin_no` as `branch_gstin_no`,
    `brstate`.`state_name` as `branch_state_name`,
    '' as `order_no`,
    '' as `delivery_type`,
    '' as `halting_charges`,
    '' as `other_charges`,
    '' as `loading_charges`,
    '' as `freight_charges`,
    ifnull(`d`.`dri_name`, '') as `dri_name`,
    ifnull(`d`.`veh_no`, '') as `veh_no`,
    ifnull(`d`.`contact1`, '') as `contact_no`,
    ifnull((select `ledgerdetails`.`comp_name` from `ledgerdetails` where (`ledgerdetails`.`ledger_id` = `d`.`transport_ledger_id`)), '') as `transport_name`,
    `cs`.`tot_tcs_amt` as `tot_tcs_amt`,
    '' as `irn_no`,
    0 as `ledger_erning_deduction`,
    (
    select
        distinct `br`.`br_name`
    from
        (`mastertransaction` `m`
    join `branch` `br` on
        ((`br`.`br_id` = `m`.`br_id`)))
    where
        (`m`.`reference_no` = `cs`.`cs_id`)) as `acc_branch`,
    `cs`.`cs_id` as `trans_id3`,
    ifnull(`l`.`contact1`, '') as `cust_contactNo`,
    concat(ifnull(`l`.`fname`, ''), ' ', ifnull(`l`.`mname`, ''), ' ', ifnull(`l`.`lname`, '')) as `res_person_name`,
    ifnull((select `itemgroups`.`grp_nm` from `itemgroups` where (`itemgroups`.`grp_code` = ifnull(`stockitems`.`grp_code`, `i`.`grp_code`))), '') as `item_group_nm`,
    ifnull((select `category`.`category` from `category` where (`category`.`category_id` = ifnull(`stockitems`.`category`, `i`.`category`))), '') as `item_category`,
    ifnull(ifnull(`stockitems`.`product_identity`, `i`.`product_identity`), '') as `item_type`,
    0 as `discount_amt`,
    `g`.`group_name` as `group_name`,
    ifnull((select `at`.`area_name` from `areastatic` `at` where (`at`.`area_code` = `l`.`area_code`)), '-') as `area_name`,
    '' as `consignee`,
    '' as `consignee_contact_no`,
    '' as `consignee_addr`,
    ifnull(`ac`.`party_code`, '') as `party_code`,
    ifnull((select concat(`employee`.`fname`, ' ', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `l`.`emp_id`)), '-') as `emp_name`,
    ifnull((select concat(`employee`.`fname`, '', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `cs`.`last_modified_by`)), '-') as `last_modified_by`,
    (
    select
        `projectmodules`.`module_name`
    from
        `projectmodules`
    where
        (`projectmodules`.`module_id` = `cp`.`module_id`)) as `module_name`,
    0 as `gst_rate`,
    `u`.`govt_unit` as `govt_unit`,
    'NO' as `is_reverse_charge`,
    '' as `sale_scheme_remark`,
    '' as `broker_id`,
    '' as `broker_name`,
    0 as `feed_distribution_amt`
from
    ((((((((((((((((((((((((((`chicksale` `cs`
join `accountcreation` `ac` on
    ((`ac`.`ledger_id` = `cs`.`trader_id`)))
join `groupcreation` `g` on
    ((`g`.`group_id` = `ac`.`group_id`)))
join `vouchercreation` `v` on
    ((`v`.`voucher_id` = `cs`.`voucher_id`)))
join `mastertransaction` `m` on
    ((`m`.`reference_no` = `cs`.`cs_id`)))
left join `vouchercreation` `vc` on
    ((`vc`.`voucher_id` = `v`.`voucher_type`)))
left join `ledgerdetails` `l` on
    ((`l`.`ledger_id` = `cs`.`trader_id`)))
left join `address` `a` on
    ((`a`.`addr_id` = `l`.`addr_id`)))
left join `city` `c` on
    ((`c`.`city_id` = `a`.`city_id`)))
left join `state` `st` on
    ((`st`.`state_id` = `a`.`state_id`)))
left join `bankdetails` `b` on
    ((`b`.`bank_id` = `l`.`bank_id`)))
join `chicksaletransaction` `cst` on
    ((`cs`.`cs_id` = `cst`.`cs_id`)))
join `chickplaced` `cp` on
    (((`cp`.`farmer_id` = `cst`.`farmer_id`)
        and (`cp`.`shed_no` = `cst`.`shed_no`)
            and (`cp`.`batch_no` = `cst`.`batch_no`))))
join `chickplacedtransaction` `cpt` on
    ((`cp`.`chick_placed_id` = `cpt`.`chick_placed_id`)))
left join `chickpurchasetransaction` `pur` on
    ((`pur`.`cpt_id` = `cpt`.`cpt_id`)))
left join `items` `i` on
    ((`i`.`i_code` = `pur`.`breed_id`)))
left join `stockin` `si` on
    ((`si`.`stock_id` = `cpt`.`op_stock_id`)))
left join `stockdetails` `sd` on
    ((`sd`.`stock_detail_id` = `si`.`stock_detail_id`)))
left join `items` `stockitems` on
    ((`stockitems`.`i_code` = `sd`.`item_id`)))
join `newfarmer` `nf` on
    ((`cst`.`farmer_id` = `nf`.`farmer_id`)))
join `newfarmerbranch` `nfb` on
    ((`nfb`.`farmer_branch_id` = `cst`.`farmer_branch_id`)))
join `branch` `br` on
    ((`br`.`br_id` = `nfb`.`branch_id`)))
join `address` `farmerad` on
    ((`br`.`addr_id` = `farmerad`.`addr_id`)))
join `state` `brstate` on
    ((`brstate`.`state_id` = `farmerad`.`state_id`)))
join `mastertransaction` `mt` on
    ((`mt`.`reference_no` = `cs`.`cs_id`)))
left join `drivertransportrecord` `d` on
    ((`d`.`trans_id` = `cs`.`trans_id`)))
left join `units` `u` on
    ((`u`.`short_name` = ifnull(`i`.`unit`, `stockitems`.`unit`))))
where
    ((`cs`.`module_id` in (1, 12, 13))
        and (not(exists(
        select
            `newfarmer`.`ledger_id`
        from
            `newfarmer`
        where
            (`newfarmer`.`ledger_id` = `cs`.`trader_id`))))
            and (`cs`.`date` between '2023-01-01' and '2024-12-31')
                and ((`v`.`voucher_id` = 'V22')
                    or (`v`.`voucher_type` = 'V22')
                        or (`vc`.`voucher_name` = 'FISH SALE')
                            or (`v`.`voucher_name` = 'FISH SALE')
                                or (`vc`.`voucher_name` = 'BULL SALE')
                                    or (`v`.`voucher_name` = 'BULL SALE')))
group by
    `cs`.`cs_id`
union
select
    distinct date_format(cast(`s`.`date` as date), '%d/%m/%Y') as `date`,
    date_format(cast(`s`.`date` as date), '%M - %Y') as `entrymonth`,
    `s`.`invoice_no` as `invoice_no`,
    ifnull(`s`.`reference_no`, '-') as `reference_no`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `s`.`ledger_id`)) as `ledger_name`,
    ifnull(`a`.`addr_l1`, '-') as `address1`,
    ifnull(`c`.`city_name`, '-') as `city_name`,
    ifnull(`st`.`state_name`, '-') as `party_state_name`,
    '-' as `tan_no`,
    '-' as `sale_tax_no`,
    ifnull(`b`.`pan_no`, '-') as `pan_no`,
    ifnull(`i`.`i_des`, `s2i`.`i_des`) as `i_des`,
    ifnull(`i`.`unit`, `s2i`.`unit`) as `unit`,
    `convert_qty_to_upper_unit`(sum(`s3`.`quantity`),
    ifnull(`i`.`i_code`, `s2i`.`i_code`)) as `quantity`,
    round(`s3`.`quantity`, 2) as `weight`,
    round(`get_rate`(`s3`.`rate`, ifnull(`i`.`i_code`, `s2i`.`i_code`), `s3`.`unit_of_rate`), 2) as `rate`,
    round(((`s3`.`quantity` * `s3`.`rate`) - (((`s3`.`quantity` * `s3`.`rate`) * `s3`.`discount`) / 100)), 2) as `prod_value`,
    ifnull(`s3`.`vat_amount`, 0) as `vat_amount`,
    `s3`.`cst_amount` as `cst_amount`,
    `s3`.`cgst_amt` as `cgst_amt`,
    `s3`.`sgst_amt` as `sgst_amt`,
    `s3`.`igst_amt` as `igst_amt`,
    `s3`.`total_cost` as `total_cost`,
    `s`.`reference_id` as `reference_id`,
    `s`.`total_amt` as `bill_amt`,
    `s`.`ledger_id` as `ledger_id`,
    ifnull(`vc`.`voucher_name`, `v`.`voucher_name`) as `voucher_name`,
    `s`.`module_id` as `module_id`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `s`.`sale_ledger_id`)) as `CR_ledger_name`,
    ifnull((select `ledgerdetails`.`gstin_no` from `ledgerdetails` where ((`ledgerdetails`.`ledger_id` = `s`.`ledger_id`) and (`ledgerdetails`.`gst_registration_date` <= `s`.`date`))), '') as `Party_gstin_no`,
    ifnull(`i`.`hsn_code`, `s2i`.`hsn_code`) as `hsn_code`,
    '' as `tracking_no`,
    ifnull(`s`.`ewaybill_no`, '-') as `ewaybill_no`,
    ifnull(`s`.`narration`, '') as `narration`,
    `s3`.`discount` as `discount`,
    `s`.`deduction` as `deduction`,
    `br`.`br_name` as `br_name`,
    `br`.`gstin_no` as `branch_gstin_no`,
    `brstate`.`state_name` as `branch_state_name`,
    ifnull(`slo`.`reference_id`,(select `salesorder`.`reference_id` from `salesorder` where (`salesorder`.`order_no` = `dn1`.`order_no`))) as `order_no`,
    ifnull(`s`.`delivery_type`, '') as `delivery_type`,
    ifnull(`s`.`halting_charges`, '') as `halting_charges`,
    ifnull(`s`.`other_charges`, '') as `other_charges`,
    ifnull(`s`.`loading_charges`, '') as `loading_charges`,
    ifnull((select `tr`.`amt` from `accounttransaction` `tr` where ((`tr`.`tr_id` = `s`.`fc_tr_id`) and (`tr`.`acc_type` = 'DR'))), 0) as `freight_charges`,
    ifnull(`d`.`dri_name`, '') as `dri_name`,
    ifnull(`d`.`veh_no`, '') as `veh_no`,
    ifnull(`d`.`contact1`, '') as `contact_no`,
    ifnull((select `ledgerdetails`.`comp_name` from `ledgerdetails` where (`ledgerdetails`.`ledger_id` = `d`.`transport_ledger_id`)), '') as `transport_name`,
    `s`.`tot_tcs_amt` as `tot_tcs_amt`,
    ifnull(`s`.`irn_no`, '') as `irn_no`,
    ifnull((select sum(`tr`.`disc_amount`) from ((`salediscountledger` `tr` join `accountcreation` `ac` on((`ac`.`ledger_id` = `tr`.`ledger_id`))) join `groupcreation` `g` on((`g`.`group_id` = `ac`.`group_id`))) where (`tr`.`invoice_no` = `s`.`invoice_no`)), 0) as `ledger_erning_deduction`,
    (
    select
        distinct `br`.`br_name`
    from
        (`mastertransaction` `m`
    join `branch` `br` on
        ((`br`.`br_id` = `m`.`br_id`)))
    where
        (`m`.`reference_no` = `s`.`invoice_no`)) as `acc_branch`,
    `s3`.`trans_id3` as `trans_id3`,
    ifnull(`ld`.`contact1`, '') as `Cust_contactNo`,
    concat(ifnull(`ld`.`fname`, ''), ' ', ifnull(`ld`.`mname`, ''), ' ', ifnull(`ld`.`lname`, '')) as `res_person_name`,
    ifnull((select `itemgroups`.`grp_nm` from `itemgroups` where (`itemgroups`.`grp_code` = ifnull(`i`.`grp_code`, `s2i`.`grp_code`))), '') as `item_group_nm`,
    ifnull((select `category`.`category` from `category` where (`category`.`category_id` = ifnull(`i`.`category`, `s2i`.`category`))), '') as `item_category`,
    ifnull(ifnull(`i`.`product_identity`, `s2i`.`product_identity`), '') as `item_type`,
    (((`s3`.`quantity` * `s3`.`rate`) * `s3`.`discount`) / 100) as `discount_amt`,
    `g`.`group_name` as `group_name`,
    ifnull((select `at`.`area_name` from `areastatic` `at` where (`at`.`area_code` = `ld`.`area_code`)), '-') as `area_name`,
    ifnull(`cd`.`consignee_name`, '') as `consignee`,
    ifnull(`cd`.`contact_no`, '') as `consignee_contact_no`,
    ifnull(`cd`.`address`, '') as `consignee_addr`,
    ifnull(`ac`.`party_code`, '') as `party_code`,
    ifnull((select concat(`employee`.`fname`, ' ', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `ld`.`emp_id`)), '-') as `emp_name`,
    ifnull((select concat(`employee`.`fname`, '', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `s`.`last_modified_by`)), '-') as `last_modified_by`,
    (
    select
        `projectmodules`.`module_name`
    from
        `projectmodules`
    where
        (`projectmodules`.`module_id` = `s`.`module_id`)) as `module_name`,
    ((`s3`.`cgst_percent` + `s3`.`sgst_percent`) + `s3`.`igst_percent`) as `gst_rate`,
    `u`.`govt_unit` as `govt_unit`,
    `s`.`is_reverse_charge` as `is_reverse_charge`,
    ifnull(`s`.`sale_scheme_remark`, '') as `sale_scheme_remark`,
    ifnull(`s`.`broker_id`, '') as `broker_id`,
    ifnull((select `accountcreation`.`ledger_name` from `accountcreation` where (`accountcreation`.`ledger_id` = `s`.`broker_id`)), '') as `broker_name`,
    ifnull((select `att`.`amt` from `accounttransaction` `att` where ((`att`.`tr_id` = `s`.`feed_distribution_jv`) and (`att`.`acc_type` = 'CR'))), 0) as `feed_distribution_amt`
from
    (((((((((((((((((((((((((((`sale` `s`
join `accountcreation` `ac` on
    ((`ac`.`ledger_id` = `s`.`ledger_id`)))
join `groupcreation` `g` on
    ((`g`.`group_id` = `ac`.`group_id`)))
left join `transaddrdetails` `traddr` on
    ((`traddr`.`tradd_id` = `s`.`transid`)))
left join `consigneedetails` `cd` on
    ((`cd`.`consignee_id` = `traddr`.`consignee_id`)))
join `vouchercreation` `v` on
    ((`v`.`voucher_id` = `s`.`voucher_id`)))
left join `ledgerdetails` `ld` on
    ((`ld`.`ledger_id` = `s`.`ledger_id`)))
left join `vouchercreation` `vc` on
    ((`vc`.`voucher_id` = `v`.`voucher_type`)))
join `salestransactions1` `s1` on
    ((`s1`.`invoice_no` = `s`.`invoice_no`)))
join `salestransactions2` `s2` on
    ((`s2`.`trans_id1` = `s1`.`trans_id1`)))
join `salestransactions3` `s3` on
    ((`s3`.`trans_id2` = `s2`.`trans_id2`)))
left join `stockout` `so` on
    ((`so`.`out_id` = `s3`.`out_id`)))
left join `stockin` `si` on
    ((`si`.`stock_id` = `so`.`stock_id`)))
left join `stockdetails` `sd` on
    ((`sd`.`stock_detail_id` = `si`.`stock_detail_id`)))
left join `items` `i` on
    ((`i`.`i_code` = `sd`.`item_id`)))
left join `items` `s2i` on
    ((`s2i`.`i_code` = `s2`.`item_id`)))
join `newfarmer` `l` on
    ((`l`.`ledger_id` = `s`.`ledger_id`)))
left join `address` `a` on
    ((`a`.`addr_id` = `l`.`ad_id`)))
left join `city` `c` on
    ((`c`.`city_id` = `a`.`city_id`)))
left join `state` `st` on
    ((`st`.`state_id` = `a`.`state_id`)))
left join `bankdetails` `b` on
    ((`b`.`bank_id` = `l`.`bank_id`)))
join `branch` `br` on
    ((`br`.`br_id` = `s`.`branch_id`)))
join `address` `braddr` on
    ((`braddr`.`addr_id` = `br`.`addr_id`)))
join `state` `brstate` on
    ((`brstate`.`state_id` = `braddr`.`state_id`)))
left join `salesorder` `slo` on
    ((`slo`.`order_no` = `s1`.`order_no`)))
left join `deliverynotetransact1` `dn1` on
    ((`dn1`.`tracking_no` = `s1`.`tracking_no`)))
left join `drivertransportrecord` `d` on
    ((`d`.`trans_id` = `s`.`transport`)))
left join `units` `u` on
    ((`u`.`short_name` = ifnull(`s2i`.`unit`, `i`.`unit`))))
where
    ((`s`.`module_id` = 1)
        and (`s`.`date` between '2023-01-01' and '2024-12-31'))
group by
    `s3`.`trans_id3`
union
select
    distinct date_format(cast(`cs`.`date` as date), '%d/%m/%Y') as `date`,
    date_format(cast(`cs`.`date` as date), '%M - %Y') as `entrymonth`,
    `cs`.`cs_id` as `invoice_no`,
    ifnull(`cs`.`dc_number`, '-') as `reference_no`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `cs`.`trader_id`)) as `ledger_name`,
    ifnull(`a`.`addr_l1`, '-') as `address1`,
    ifnull(`c`.`city_name`, '-') as `city_name`,
    ifnull(`st`.`state_name`, '-') as `party_state_name`,
    '-' as `tan_no`,
    '-' as `sale_tax_no`,
    ifnull(`b`.`pan_no`, '-') as `pan_no`,
    ifnull(`stockitems`.`i_des`, `i`.`i_des`) as `i_des`,
    ifnull(`stockitems`.`unit`, `i`.`unit`) as `unit`,
    `cs`.`tot_b_sold` as `quantity`,
    round(`cs`.`total_wt`, 2) as `weight`,
    `cs`.`rate` as `rate`,
    `cs`.`amt` as `prod_value`,
    0 as `vat_amount`,
    0 as `cst_amount`,
    0 as `cgst_amt`,
    0 as `sgst_amt`,
    0 as `igst_amt`,
    `cs`.`amt` as `total_cost`,
    `cs`.`reference_id` as `reference_id`,
    `cs`.`net_amt` as `bill_amt`,
    `cs`.`trader_id` as `ledger_id`,
    ifnull(`vc`.`voucher_name`, `v`.`voucher_name`) as `voucher_name`,
    `m`.`module_id` as `module_id`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `cs`.`sale_ledger_id`)) as `CR_ledger_name`,
    ifnull((select `ledgerdetails`.`gstin_no` from `ledgerdetails` where ((`ledgerdetails`.`ledger_id` = `cs`.`trader_id`) and (`ledgerdetails`.`gst_registration_date` <= `cs`.`date`))), '') as `Party_gstin_no`,
    ifnull(`stockitems`.`hsn_code`, `i`.`hsn_code`) as `hsn_code`,
    '' as `tracking_no`,
    '' as `ewaybill_no`,
    ifnull(`mt`.`narration`, '') as `narration`,
    0 as `discount`,
    0 as `deduction`,
    `br`.`br_name` as `br_name`,
    `br`.`gstin_no` as `branch_gstin_no`,
    `brstate`.`state_name` as `branch_state_name`,
    '' as `order_no`,
    '' as `delivery_type`,
    '' as `halting_charges`,
    '' as `other_charges`,
    '' as `loading_charges`,
    '' as `freight_charges`,
    ifnull(`d`.`dri_name`, '') as `dri_name`,
    ifnull(`d`.`veh_no`, '') as `veh_no`,
    ifnull(`d`.`contact1`, '') as `contact_no`,
    ifnull((select `ledgerdetails`.`comp_name` from `ledgerdetails` where (`ledgerdetails`.`ledger_id` = `d`.`transport_ledger_id`)), '') as `transport_name`,
    `cs`.`tot_tcs_amt` as `tot_tcs_amt`,
    '' as `irn_no`,
    0 as `ledger_erning_deduction`,
    (
    select
        distinct `br`.`br_name`
    from
        (`mastertransaction` `m`
    join `branch` `br` on
        ((`br`.`br_id` = `m`.`br_id`)))
    where
        (`m`.`reference_no` = `cs`.`cs_id`)) as `acc_branch`,
    `cs`.`cs_id` as `trans_id3`,
    ifnull(`ld`.`contact1`, '') as `Cust_contactNo`,
    concat(ifnull(`ld`.`fname`, ''), ' ', ifnull(`ld`.`mname`, ''), ' ', ifnull(`ld`.`lname`, '')) as `res_person_name`,
    ifnull((select `itemgroups`.`grp_nm` from `itemgroups` where (`itemgroups`.`grp_code` = ifnull(`stockitems`.`grp_code`, `i`.`grp_code`))), '') as `item_group_nm`,
    ifnull((select `category`.`category` from `category` where (`category`.`category_id` = ifnull(`stockitems`.`category`, `i`.`category`))), '') as `item_category`,
    ifnull(ifnull(`stockitems`.`product_identity`, `i`.`product_identity`), '') as `item_type`,
    0 as `discount_amt`,
    `g`.`group_name` as `group_name`,
    ifnull((select `at`.`area_name` from `areastatic` `at` where (`at`.`area_code` = `ld`.`area_code`)), '-') as `area_name`,
    '' as `consignee`,
    '' as `consignee_contact_no`,
    '' as `consignee_addr`,
    ifnull(`ac`.`party_code`, '') as `party_code`,
    ifnull((select concat(`employee`.`fname`, ' ', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `ld`.`emp_id`)), '-') as `emp_name`,
    ifnull((select concat(`employee`.`fname`, '', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `cs`.`last_modified_by`)), '-') as `last_modified_by`,
    (
    select
        `projectmodules`.`module_name`
    from
        `projectmodules`
    where
        (`projectmodules`.`module_id` = `cp`.`module_id`)) as `module_name`,
    0 as `gst_rate`,
    `u`.`govt_unit` as `govt_unit`,
    'NO' as `is_reverse_charge`,
    '' as `sale_scheme_remark`,
    '' as `broker_id`,
    '' as `broker_name`,
    0 as `feed_distribution_amt`
from
    (((((((((((((((((((((((((((`chicksale` `cs`
join `accountcreation` `ac` on
    ((`ac`.`ledger_id` = `cs`.`trader_id`)))
join `groupcreation` `g` on
    ((`g`.`group_id` = `ac`.`group_id`)))
join `vouchercreation` `v` on
    ((`v`.`voucher_id` = `cs`.`voucher_id`)))
join `mastertransaction` `m` on
    ((`m`.`reference_no` = `cs`.`cs_id`)))
left join `ledgerdetails` `ld` on
    ((`ld`.`ledger_id` = `cs`.`trader_id`)))
left join `vouchercreation` `vc` on
    ((`vc`.`voucher_id` = `v`.`voucher_type`)))
join `newfarmer` `l` on
    ((`l`.`ledger_id` = `cs`.`trader_id`)))
left join `address` `a` on
    ((`a`.`addr_id` = `l`.`ad_id`)))
left join `city` `c` on
    ((`c`.`city_id` = `a`.`city_id`)))
left join `state` `st` on
    ((`st`.`state_id` = `a`.`state_id`)))
left join `bankdetails` `b` on
    ((`b`.`bank_id` = `l`.`bank_id`)))
join `chicksaletransaction` `cst` on
    ((`cs`.`cs_id` = `cst`.`cs_id`)))
join `chickplaced` `cp` on
    (((`cp`.`farmer_id` = `cst`.`farmer_id`)
        and (`cp`.`shed_no` = `cst`.`shed_no`)
            and (`cp`.`batch_no` = `cst`.`batch_no`))))
join `chickplacedtransaction` `cpt` on
    ((`cp`.`chick_placed_id` = `cpt`.`chick_placed_id`)))
left join `chickpurchasetransaction` `pur` on
    ((`pur`.`cpt_id` = `cpt`.`cpt_id`)))
left join `items` `i` on
    ((`i`.`i_code` = `pur`.`breed_id`)))
left join `stockin` `si` on
    ((`si`.`stock_id` = `cpt`.`op_stock_id`)))
left join `stockdetails` `sd` on
    ((`sd`.`stock_detail_id` = `si`.`stock_detail_id`)))
left join `items` `stockitems` on
    ((`stockitems`.`i_code` = `sd`.`item_id`)))
join `newfarmer` `nf` on
    ((`cst`.`farmer_id` = `nf`.`farmer_id`)))
join `newfarmerbranch` `nfb` on
    ((`nfb`.`farmer_branch_id` = `cst`.`farmer_branch_id`)))
join `branch` `br` on
    ((`br`.`br_id` = `nfb`.`branch_id`)))
join `address` `farmerad` on
    ((`br`.`addr_id` = `farmerad`.`addr_id`)))
join `state` `brstate` on
    ((`brstate`.`state_id` = `farmerad`.`state_id`)))
join `mastertransaction` `mt` on
    ((`mt`.`reference_no` = `cs`.`cs_id`)))
left join `drivertransportrecord` `d` on
    ((`d`.`trans_id` = `cs`.`trans_id`)))
left join `units` `u` on
    ((`u`.`short_name` = ifnull(`stockitems`.`unit`, `i`.`unit`))))
where
    ((`cs`.`date` between '2023-01-01' and '2024-12-31')
        and (`cs`.`module_id` in (1, 12, 13))
            and ((`v`.`voucher_id` = 'V22')
                or (`v`.`voucher_type` = 'V22')
                    or (`vc`.`voucher_name` = 'FISH SALE')
                        or (`v`.`voucher_name` = 'FISH SALE')
                            or (`vc`.`voucher_name` = 'BULL SALE')
                                or (`v`.`voucher_name` = 'BULL SALE')))
group by
    `cs`.`cs_id`
union
select
    distinct date_format(cast(`bs`.`date` as date), '%d/%m/%Y') as `date`,
    date_format(cast(`bs`.`date` as date), '%M - %Y') as `entrymonth`,
    `bs`.`sale_id` as `invoice_no`,
    ifnull(`bs`.`dc_no`, '') as `reference_no`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `bs`.`ledger_id`)) as `ledger_name`,
    ifnull(`ledad`.`addr_l1`, '-') as `address1`,
    ifnull(`ct`.`city_name`, '-') as `city_name`,
    ifnull(`s`.`state_name`, '-') as `party_state_name`,
    ifnull(`l`.`tan_no`, '-') as `tan_no`,
    ifnull(`l`.`sale_tax_no`, '-') as `sale_tax_no`,
    ifnull(`b`.`pan_no`, '-') as `pan_no`,
    (
    select
        `i`.`i_des`
    from
        ((`items` `i`
    join `batch` `b` on
        ((`i`.`i_code` = `b`.`breeder_id`)))
    join `chicksplacement` `c` on
        (((`c`.`b_id` = `b`.`b_id`)
            and (`c`.`module_id` = `b`.`module_id`))))
    where
        (`c`.`placement_id` = `bs1`.`placement_id`)) as `i_des`,
    (
    select
        `i`.`unit`
    from
        ((`items` `i`
    join `batch` `b` on
        ((`i`.`i_code` = `b`.`breeder_id`)))
    join `chicksplacement` `c` on
        (((`c`.`b_id` = `b`.`b_id`)
            and (`c`.`module_id` = `b`.`module_id`))))
    where
        (`c`.`placement_id` = `bs1`.`placement_id`)) as `unit`,
    ifnull(sum((ifnull(`b1`.`f_sale_qty`, 0) + ifnull(`b1`.`m_sale_qty`, 0))), 0) as `quantity`,
    round(`bs1`.`total_weight`, 2) as `weight`,
    `bs`.`rate_per_bird` as `rate`,
    `bs1`.`amount1` as `prod_value`,
    0 as `vat_amount`,
    0 as `cst_amount`,
    0 as `cgst_amt`,
    0 as `sgst_amt`,
    0 as `igst_amt`,
    `bs1`.`amount1` as `total_cost`,
    `bs`.`reference_id` as `reference_id`,
    `bs`.`amount` as `bill_amt`,
    `bs`.`ledger_id` as `ledger_id`,
    ifnull(`vc`.`voucher_name`, `v`.`voucher_name`) as `voucher_name`,
    `bs`.`module_id` as `module_id`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `bs`.`sale_ledger_id`)) as `CR_ledger_name`,
    ifnull((select `ledgerdetails`.`gstin_no` from `ledgerdetails` where ((`ledgerdetails`.`ledger_id` = `bs`.`ledger_id`) and (`ledgerdetails`.`gst_registration_date` <= `bs`.`date`))), '') as `Party_gstin_no`,
    (
    select
        `i`.`hsn_code`
    from
        ((`items` `i`
    join `batch` `b` on
        ((`i`.`i_code` = `b`.`breeder_id`)))
    join `chicksplacement` `c` on
        (((`c`.`b_id` = `b`.`b_id`)
            and (`c`.`module_id` = `b`.`module_id`))))
    where
        (`c`.`placement_id` = `bs1`.`placement_id`)) as `hsn_code`,
    '' as `tracking_no`,
    '' as `ewaybill_no`,
    ifnull(`bs`.`narration`, '') as `narration`,
    0 as `discount`,
    0 as `deduction`,
    `br`.`br_name` as `br_name`,
    `br`.`gstin_no` as `branch_gstin_no`,
    `brstate`.`state_name` as `branch_state_name`,
    '' as `order_no`,
    '' as `delivery_type`,
    '' as `halting_charges`,
    '' as `other_charges`,
    '' as `loading_charges`,
    '' as `freight_charges`,
    '' as `dri_name`,
    '' as `veh_no`,
    '' as `contact_no`,
    '' as `transport_name`,
    `bs`.`tot_tcs_amt` as `tot_tcs_amt`,
    '' as `irn_no`,
    0 as `ledger_erning_deduction`,
    (
    select
        distinct `br`.`br_name`
    from
        (`mastertransaction` `m`
    join `branch` `br` on
        ((`br`.`br_id` = `m`.`br_id`)))
    where
        (`m`.`reference_no` = `bs`.`sale_id`)) as `acc_branch`,
    `bs1`.`t_id` as `trans_id3`,
    ifnull(`l`.`contact1`, '') as `Cust_contactNo`,
    concat(ifnull(`l`.`fname`, ''), ' ', ifnull(`l`.`mname`, ''), ' ', ifnull(`l`.`lname`, '')) as `res_person_name`,
    ifnull((select `ig`.`grp_nm` from (((`items` `i` join `itemgroups` `ig` on((`ig`.`grp_code` = `i`.`grp_code`))) join `batch` `b` on((`i`.`i_code` = `b`.`breeder_id`))) join `chicksplacement` `c` on(((`c`.`b_id` = `b`.`b_id`) and (`c`.`module_id` = `b`.`module_id`)))) where (`c`.`placement_id` = `bs1`.`placement_id`)), '') as `item_group_nm`,
    ifnull((select `ct`.`category` from (((`items` `i` join `category` `ct` on((`ct`.`category_id` = `i`.`category`))) join `batch` `b` on((`i`.`i_code` = `b`.`breeder_id`))) join `chicksplacement` `c` on(((`c`.`b_id` = `b`.`b_id`) and (`c`.`module_id` = `b`.`module_id`)))) where (`c`.`placement_id` = `bs1`.`placement_id`)), '') as `item_category`,
    '' as `item_type`,
    0 as `discount_amt`,
    `g`.`group_name` as `group_name`,
    ifnull((select `at`.`area_name` from `areastatic` `at` where (`at`.`area_code` = `l`.`area_code`)), '-') as `area_name`,
    '' as `consignee`,
    '' as `consignee_contact_no`,
    '' as `consignee_addr`,
    ifnull(`ac`.`party_code`, '') as `party_code`,
    ifnull((select concat(`employee`.`fname`, ' ', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `l`.`emp_id`)), '-') as `emp_name`,
    ifnull((select concat(`employee`.`fname`, '', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `bs`.`last_modified_by`)), '-') as `last_modified_by`,
    (
    select
        `projectmodules`.`module_name`
    from
        `projectmodules`
    where
        (`projectmodules`.`module_id` = `bs`.`module_id`)) as `module_name`,
    0 as `gst_rate`,
    '' as `govt_unit`,
    '' as `is_reverse_charge`,
    '' as `sale_scheme_remark`,
    '' as `broker_id`,
    '' as `broker_name`,
    0 as `feed_distribution_amt`
from
    ((((((((((((((`bchicksale` `bs`
join `accountcreation` `ac` on
    ((`ac`.`ledger_id` = `bs`.`ledger_id`)))
join `groupcreation` `g` on
    ((`g`.`group_id` = `ac`.`group_id`)))
join `bchicksaletrans` `bs1` on
    ((`bs1`.`sale_id` = `bs`.`sale_id`)))
join `bchicksale1` `b1` on
    (((`b1`.`t_id` = `bs1`.`t_id`)
        and (`b1`.`sale_id` = `bs`.`sale_id`))))
left join `ledgerdetails` `l` on
    ((`l`.`ledger_id` = `bs`.`ledger_id`)))
left join `address` `ledad` on
    ((`ledad`.`addr_id` = `l`.`addr_id`)))
left join `state` `s` on
    ((`s`.`state_id` = `ledad`.`state_id`)))
left join `city` `ct` on
    ((`ct`.`city_id` = `ledad`.`city_id`)))
left join `bankdetails` `b` on
    ((`b`.`bank_id` = `l`.`bank_id`)))
join `branch` `br` on
    ((`br`.`br_id` = `bs`.`branch_id`)))
join `address` `branchad` on
    ((`branchad`.`addr_id` = `br`.`addr_id`)))
join `state` `brstate` on
    ((`brstate`.`state_id` = `branchad`.`state_id`)))
join `vouchercreation` `v` on
    ((`v`.`voucher_id` = `bs`.`voucher_id`)))
left join `vouchercreation` `vc` on
    ((`vc`.`voucher_id` = `v`.`voucher_type`)))
where
    ((`bs`.`date` between '2023-01-01' and '2024-12-31')
        and (`bs`.`module_id` in (2, 5, 11)))
group by
    `bs1`.`t_id`
union
select
    distinct date_format(cast(`bs`.`date` as date), '%d/%m/%Y') as `date`,
    date_format(cast(`bs`.`date` as date), '%M - %Y') as `entrymonth`,
    `bs`.`cs_id` as `invoice_no`,
    '' as `reference_no`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `bs`.`ledger_id`)) as `ledger_name`,
    ifnull(`ledad`.`addr_l1`, '-') as `address1`,
    ifnull(`ct`.`city_name`, '-') as `city_name`,
    ifnull(`s`.`state_name`, '-') as `party_state_name`,
    ifnull(`l`.`tan_no`, '-') as `tan_no`,
    ifnull(`l`.`sale_tax_no`, '-') as `sale_tax_no`,
    ifnull(`b`.`pan_no`, '-') as `pan_no`,
    (
    select
        `i`.`i_des`
    from
        ((`items` `i`
    join `batch` `b` on
        ((`i`.`i_code` = `b`.`breeder_id`)))
    join `chicksplacement` `c` on
        (((`c`.`b_id` = `b`.`b_id`)
            and (`c`.`module_id` = `b`.`module_id`))))
    where
        (`c`.`placement_id` = `bs1`.`placement_id`)) as `i_des`,
    (
    select
        `i`.`unit`
    from
        ((`items` `i`
    join `batch` `b` on
        ((`i`.`i_code` = `b`.`breeder_id`)))
    join `chicksplacement` `c` on
        (((`c`.`b_id` = `b`.`b_id`)
            and (`c`.`module_id` = `b`.`module_id`))))
    where
        (`c`.`placement_id` = `bs1`.`placement_id`)) as `unit`,
    0 as `quantity`,
    round(`bs1`.`total_weight`, 2) as `weight`,
    `bs`.`rate_per_bird` as `rate`,
    `bs1`.`amount1` as `prod_value`,
    0 as `vat_amount`,
    0 as `cst_amount`,
    0 as `cgst_amt`,
    0 as `sgst_amt`,
    0 as `igst_amt`,
    `bs1`.`amount1` as `total_cost`,
    `bs`.`reference_id` as `reference_id`,
    `bs`.`amount` as `bill_amt`,
    `bs`.`ledger_id` as `ledger_id`,
    ifnull(`vc`.`voucher_name`, `v`.`voucher_name`) as `voucher_name`,
    `bs`.`module_id` as `module_id`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `bs`.`sale_ledger_id`)) as `CR_ledger_name`,
    ifnull((select `ledgerdetails`.`gstin_no` from `ledgerdetails` where ((`ledgerdetails`.`ledger_id` = `bs`.`ledger_id`) and (`ledgerdetails`.`gst_registration_date` <= `bs`.`date`))), '') as `Party_gstin_no`,
    (
    select
        `i`.`hsn_code`
    from
        ((`items` `i`
    join `batch` `b` on
        ((`i`.`i_code` = `b`.`breeder_id`)))
    join `chicksplacement` `c` on
        (((`c`.`b_id` = `b`.`b_id`)
            and (`c`.`module_id` = `b`.`module_id`))))
    where
        (`c`.`placement_id` = `bs1`.`placement_id`)) as `hsn_code`,
    '' as `tracking_no`,
    '' as `ewaybill_no`,
    ifnull(`bs`.`narration`, '') as `narration`,
    0 as `discount`,
    0 as `deduction`,
    `br`.`br_name` as `br_name`,
    `br`.`gstin_no` as `branch_gstin_no`,
    `brstate`.`state_name` as `branch_state_name`,
    '' as `order_no`,
    '' as `delivery_type`,
    '' as `halting_charges`,
    '' as `other_charges`,
    '' as `loading_charges`,
    '' as `freight_charges`,
    '' as `dri_name`,
    '' as `veh_no`,
    '' as `contact_no`,
    '' as `transport_name`,
    `bs`.`tot_tcs_amt` as `tot_tcs_amt`,
    '' as `irn_no`,
    0 as `ledger_erning_deduction`,
    (
    select
        distinct `br`.`br_name`
    from
        (`mastertransaction` `m`
    join `branch` `br` on
        ((`br`.`br_id` = `m`.`br_id`)))
    where
        (`m`.`reference_no` = `bs`.`cs_id`)) as `acc_branch`,
    `bs1`.`t_id` as `trans_id3`,
    ifnull(`l`.`contact1`, '') as `Cust_contactNo`,
    concat(ifnull(`l`.`fname`, ''), ' ', ifnull(`l`.`mname`, ''), ' ', ifnull(`l`.`lname`, '')) as `res_person_name`,
    ifnull((select `ig`.`grp_nm` from (((`items` `i` join `itemgroups` `ig` on((`ig`.`grp_code` = `i`.`grp_code`))) join `batch` `b` on((`i`.`i_code` = `b`.`breeder_id`))) join `chicksplacement` `c` on(((`c`.`b_id` = `b`.`b_id`) and (`c`.`module_id` = `b`.`module_id`)))) where (`c`.`placement_id` = `bs1`.`placement_id`)), '') as `item_group_nm`,
    ifnull((select `ct`.`category` from (((`items` `i` join `category` `ct` on((`ct`.`category_id` = `i`.`category`))) join `batch` `b` on((`i`.`i_code` = `b`.`breeder_id`))) join `chicksplacement` `c` on(((`c`.`b_id` = `b`.`b_id`) and (`c`.`module_id` = `b`.`module_id`)))) where (`c`.`placement_id` = `bs1`.`placement_id`)), '') as `item_category`,
    '' as `item_type`,
    0 as `discount_amt`,
    `g`.`group_name` as `group_name`,
    ifnull((select `at`.`area_name` from `areastatic` `at` where (`at`.`area_code` = `l`.`area_code`)), '-') as `area_name`,
    '' as `consignee`,
    '' as `consignee_contact_no`,
    '' as `consignee_addr`,
    ifnull(`ac`.`party_code`, '') as `party_code`,
    ifnull((select concat(`employee`.`fname`, ' ', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `l`.`emp_id`)), '-') as `emp_name`,
    ifnull((select concat(`employee`.`fname`, '', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `bs`.`last_modified_by`)), '-') as `last_modified_by`,
    (
    select
        `projectmodules`.`module_name`
    from
        `projectmodules`
    where
        (`projectmodules`.`module_id` = `bs`.`module_id`)) as `module_name`,
    0 as `gst_rate`,
    '' as `govt_unit`,
    '' as `is_reverse_charge`,
    '' as `sale_scheme_remark`,
    '' as `broker_id`,
    '' as `broker_name`,
    0 as `feed_distribution_amt`
from
    (((((((((((((`cullsale` `bs`
join `accountcreation` `ac` on
    ((`ac`.`ledger_id` = `bs`.`ledger_id`)))
join `groupcreation` `g` on
    ((`g`.`group_id` = `ac`.`group_id`)))
join `cullsaletrans1` `bs1` on
    ((`bs1`.`cs_id` = `bs`.`cs_id`)))
left join `ledgerdetails` `l` on
    ((`l`.`ledger_id` = `bs`.`ledger_id`)))
left join `address` `ledad` on
    ((`ledad`.`addr_id` = `l`.`addr_id`)))
left join `state` `s` on
    ((`s`.`state_id` = `ledad`.`state_id`)))
left join `city` `ct` on
    ((`ct`.`city_id` = `ledad`.`city_id`)))
left join `bankdetails` `b` on
    ((`b`.`bank_id` = `l`.`bank_id`)))
join `branch` `br` on
    ((`br`.`br_id` = `bs`.`branch_id`)))
join `address` `branchad` on
    ((`branchad`.`addr_id` = `br`.`addr_id`)))
join `state` `brstate` on
    ((`brstate`.`state_id` = `branchad`.`state_id`)))
join `vouchercreation` `v` on
    ((`v`.`voucher_id` = `bs`.`voucher_id`)))
left join `vouchercreation` `vc` on
    ((`vc`.`voucher_id` = `v`.`voucher_type`)))
where
    ((`bs`.`date` between '2023-01-01' and '2024-12-31')
        and (`bs`.`module_id` in (2, 5, 11)))
group by
    `bs1`.`t_id`
union
select
    distinct date_format(cast(`es`.`date` as date), '%d/%m/%Y') as `date`,
    date_format(cast(`es`.`date` as date), '%M - %Y') as `entrymonth`,
    `es`.`invoice_no` as `invoice_no`,
    ifnull(`es`.`reference_no`, '-') as `reference_no`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `es`.`ledger_id`)) as `ledger_name`,
    ifnull(`ledad`.`addr_l1`, '-') as `address1`,
    ifnull(`ct`.`city_name`, '-') as `city_name`,
    ifnull(`s`.`state_name`, '-') as `party_state_name`,
    ifnull(`l`.`tan_no`, '-') as `tan_no`,
    ifnull(`l`.`sale_tax_no`, '-') as `sale_tax_no`,
    ifnull(`b`.`pan_no`, '-') as `pan_no`,
    `i`.`i_des` as `i_des`,
    `i`.`unit` as `unit`,
    `es3`.`delivered_qty` as `quantity`,
    round(`es3`.`delivered_qty`, 2) as `weight`,
    round(`es3`.`rate_per_egg`, 2) as `rate`,
    round((`es3`.`delivered_qty` * `es3`.`rate_per_egg`), 2) as `prod_value`,
    0 as `vat_amount`,
    0 as `cst_amount`,
    0 as `cgst_amt`,
    0 as `sgst_amt`,
    0 as `igst_amt`,
    `es3`.`total_cost` as `total_cost`,
    `es`.`reference_id` as `reference_id`,
    `es`.`total_amt` as `bill_amt`,
    `es`.`ledger_id` as `ledger_id`,
    ifnull(`vc`.`voucher_name`, `v`.`voucher_name`) as `voucher_name`,
    `es`.`module_id` as `module_id`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `es`.`sale_ledger_id`)) as `CR_ledger_name`,
    ifnull((select `ledgerdetails`.`gstin_no` from `ledgerdetails` where ((`ledgerdetails`.`ledger_id` = `es`.`ledger_id`) and (`ledgerdetails`.`gst_registration_date` <= `es`.`date`))), '') as `Party_gstin_no`,
    ifnull(`i`.`hsn_code`, '') as `hsn_code`,
    ifnull(concat(`dn`.`reference_id`, ' (', convert(date_format(`dn`.`date`, '%d/%m/%y') using latin1), ')'), '') as `tracking_no`,
    ifnull(`es`.`ewaybill_no`, '-') as `ewaybill_no`,
    ifnull(`es`.`narration`, '') as `narration`,
    `es3`.`discount` as `discount`,
    `es`.`deduction` as `deduction`,
    `br`.`br_name` as `br_name`,
    `br`.`gstin_no` as `branch_gstin_no`,
    `brstate`.`state_name` as `branch_state_name`,
    ifnull(`slo`.`reference_id`,(select `salesorder`.`reference_id` from `salesorder` where (`salesorder`.`order_no` = `dn1`.`order_no`))) as `order_no`,
    ifnull(`es`.`delivery_type`, '') as `delivery_type`,
    '' as `halting_charges`,
    ifnull(`es`.`other_charges`, '') as `other_charges`,
    '' as `loading_charges`,
    0 as `freight_charges`,
    ifnull(`d`.`dri_name`, '') as `dri_name`,
    ifnull(`d`.`veh_no`, '') as `veh_no`,
    ifnull(`d`.`contact1`, '') as `contact_no`,
    ifnull((select `ledgerdetails`.`comp_name` from `ledgerdetails` where (`ledgerdetails`.`ledger_id` = `d`.`transport_ledger_id`)), '') as `transport_name`,
    `es`.`tot_tcs_amt` as `tot_tcs_amt`,
    ifnull(`es`.`irn_no`, '') as `irn_no`,
    0 as `ledger_erning_deduction`,
    (
    select
        distinct `br`.`br_name`
    from
        (`mastertransaction` `m`
    join `branch` `br` on
        ((`br`.`br_id` = `m`.`br_id`)))
    where
        (`m`.`reference_no` = `es`.`invoice_no`)) as `acc_branch`,
    `es3`.`trans_id3` as `trans_id3`,
    ifnull(`l`.`contact1`, '') as `Cust_contactNo`,
    concat(ifnull(`l`.`fname`, ''), ' ', ifnull(`l`.`mname`, ''), ' ', ifnull(`l`.`lname`, '')) as `res_person_name`,
    ifnull((select `itemgroups`.`grp_nm` from `itemgroups` where (`itemgroups`.`grp_code` = `i`.`grp_code`)), '') as `item_group_nm`,
    ifnull((select `category`.`category` from `category` where (`category`.`category_id` = `i`.`category`)), '') as `item_category`,
    ifnull(`i`.`product_identity`, '') as `item_type`,
    (((`es3`.`delivered_qty` * `es3`.`rate_per_egg`) * `es3`.`discount`) / 100) as `discount_amt`,
    `g`.`group_name` as `group_name`,
    ifnull((select `at`.`area_name` from `areastatic` `at` where (`at`.`area_code` = `l`.`area_code`)), '-') as `area_name`,
    ifnull(`cd`.`consignee_name`, '') as `consignee`,
    ifnull(`cd`.`contact_no`, '') as `consignee_contact_no`,
    ifnull(`cd`.`address`, '') as `consignee_addr`,
    ifnull(`ac`.`party_code`, '') as `party_code`,
    ifnull((select concat(`employee`.`fname`, ' ', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `l`.`emp_id`)), '-') as `emp_name`,
    ifnull((select concat(`employee`.`fname`, '', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `es`.`last_modified_by`)), '-') as `last_modified_by`,
    (
    select
        `projectmodules`.`module_name`
    from
        `projectmodules`
    where
        (`projectmodules`.`module_id` = `es`.`module_id`)) as `module_name`,
    0 as `gst_rate`,
    `u`.`govt_unit` as `govt_unit`,
    `es`.`is_reverse_charge` as `is_reverse_charge`,
    ifnull(`es`.`sale_scheme_remark`, '') as `sale_scheme_remark`,
    '' as `broker_id`,
    '' as `broker_name`,
    0 as `feed_distribution_amt`
from
    (((((((((((((((((((((((`sale` `es`
join `accountcreation` `ac` on
    ((`ac`.`ledger_id` = `es`.`ledger_id`)))
join `groupcreation` `g` on
    ((`g`.`group_id` = `ac`.`group_id`)))
left join `transaddrdetails` `traddr` on
    ((`traddr`.`tradd_id` = `es`.`transid`)))
left join `consigneedetails` `cd` on
    ((`cd`.`consignee_id` = `traddr`.`consignee_id`)))
left join `ledgerdetails` `l` on
    ((`l`.`ledger_id` = `es`.`ledger_id`)))
left join `address` `ledad` on
    ((`ledad`.`addr_id` = `l`.`addr_id`)))
left join `state` `s` on
    ((`s`.`state_id` = `ledad`.`state_id`)))
left join `city` `ct` on
    ((`ct`.`city_id` = `ledad`.`city_id`)))
left join `bankdetails` `b` on
    ((`b`.`bank_id` = `l`.`bank_id`)))
join `salestransactions1` `s1` on
    ((`es`.`invoice_no` = `s1`.`invoice_no`)))
join `eggsalestransactions2` `es2` on
    ((`s1`.`trans_id1` = `es2`.`trans_id1`)))
join `eggsalestransactions3` `es3` on
    ((`es3`.`trans_id2` = `es2`.`trans_id2`)))
left join `deliverynote` `dn` on
    ((`dn`.`tracking_no` = `s1`.`tracking_no`)))
join `items` `i` on
    ((`i`.`i_code` = `es2`.`item_id`)))
join `branch` `br` on
    ((`br`.`br_id` = `es`.`branch_id`)))
join `address` `braddr` on
    ((`braddr`.`addr_id` = `br`.`addr_id`)))
join `state` `brstate` on
    ((`brstate`.`state_id` = `braddr`.`state_id`)))
join `vouchercreation` `v` on
    ((`v`.`voucher_id` = `es`.`voucher_id`)))
left join `vouchercreation` `vc` on
    ((`vc`.`voucher_id` = `v`.`voucher_type`)))
left join `salesorder` `slo` on
    ((`slo`.`order_no` = `s1`.`order_no`)))
left join `deliverynotetransact1` `dn1` on
    ((`dn1`.`tracking_no` = `s1`.`tracking_no`)))
left join `drivertransportrecord` `d` on
    ((`d`.`trans_id` = `es`.`transport`)))
join `units` `u` on
    ((`u`.`short_name` = `i`.`unit`)))
where
    ((`es`.`date` between '2023-01-01' and '2024-12-31')
        and (`es`.`module_id` in (2, 5, 11)))
group by
    `es3`.`trans_id3`
union
select
    distinct date_format(cast(`s`.`date` as date), '%d/%m/%Y') as `date`,
    date_format(cast(`s`.`date` as date), '%M - %Y') as `entrymonth`,
    `s`.`invoice_no` as `invoice_no`,
    ifnull(`s`.`reference_no`, '-') as `reference_no`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `s`.`ledger_id`)) as `ledger_name`,
    ifnull(`ledadr`.`addr_l1`, '-') as `address1`,
    ifnull(`ct`.`city_name`, '-') as `city_name`,
    ifnull(`st`.`state_name`, '-') as `party_state_name`,
    ifnull(`l`.`tan_no`, '-') as `tan_no`,
    ifnull(`l`.`sale_tax_no`, '-') as `sale_tax_no`,
    ifnull(`b`.`pan_no`, '-') as `pan_no`,
    `i`.`i_des` as `i_des`,
    `i`.`unit` as `unit`,
    (((`s3`.`quantity` - `s3`.`short`) - `s3`.`mortality`) - `s3`.`culls`) as `quantity`,
    round((((`s3`.`quantity` - `s3`.`short`) - `s3`.`mortality`) - `s3`.`culls`), 2) as `weight`,
    round(`s3`.`rate`, 2) as `rate`,
    (case
        when exists(
        select
            `ac`.`ledger_name`
        from
            ((`mastertransaction` `m`
        join `accounttransaction` `at` on
            ((`m`.`tr_id` = `at`.`tr_id`)))
        join `accountcreation` `ac` on
            (((`at`.`ledger_id` = `ac`.`ledger_id`)
                and (`ac`.`ledger_name` = 'discount sale'))))
        where
            (`m`.`reference_no` = `s`.`invoice_no`)) then round(((((`s3`.`quantity` - `s3`.`short`) - `s3`.`mortality`) - `s3`.`culls`) * `s3`.`rate`), 2)
        else (round((((((`s3`.`quantity` - `s3`.`short`) - `s3`.`mortality`) - `s3`.`culls`) * 100) / (100 + `s3`.`discount`)), 0) * `s3`.`rate`)
    end) as `prod_value`,
    0 as `vat_amount`,
    0 as `cst_amount`,
    0 as `cgst_amt`,
    0 as `sgst_amt`,
    0 as `igst_amt`,
    (round((((((`s3`.`quantity` - `s3`.`short`) - `s3`.`mortality`) - `s3`.`culls`) * 100) / (100 + `s3`.`discount`)), 0) * `s3`.`rate`) as `total_cost`,
    `s`.`reference_id` as `reference_id`,
    `s`.`total_amt` as `bill_amt`,
    `s`.`ledger_id` as `ledger_id`,
    ifnull(`vc`.`voucher_name`, `v`.`voucher_name`) as `voucher_name`,
    `s`.`module_id` as `module_id`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `s`.`sale_ledger_id`)) as `CR_ledger_name`,
    ifnull((select `ledgerdetails`.`gstin_no` from `ledgerdetails` where ((`ledgerdetails`.`ledger_id` = `s`.`ledger_id`) and (`ledgerdetails`.`gst_registration_date` <= `s`.`date`))), '') as `Party_gstin_no`,
    ifnull(`i`.`hsn_code`, '') as `hsn_code`,
    ifnull(concat(`dn`.`reference_id`, ' (', convert(date_format(`dn`.`date`, '%d/%m/%y') using latin1), ')'), '') as `tracking_no`,
    ifnull(`s`.`ewaybill_no`, '-') as `ewaybill_no`,
    ifnull(`s`.`narration`, '') as `narration`,
    `s3`.`discount` as `discount`,
    `s`.`deduction` as `deduction`,
    `br`.`br_name` as `br_name`,
    `br`.`gstin_no` as `branch_gstin_no`,
    `brstate`.`state_name` as `branch_state_name`,
    '' as `order_no`,
    ifnull(`s`.`delivery_type`, '') as `delivery_type`,
    0 as `halting_charges`,
    ifnull(`s`.`other_charges`, '') as `other_charges`,
    0 as `loading_charges`,
    0 as `freight_charges`,
    ifnull(`d`.`dri_name`, '') as `dri_name`,
    ifnull(`d`.`veh_no`, '') as `veh_no`,
    ifnull(`d`.`contact1`, '') as `contact_no`,
    ifnull((select `ledgerdetails`.`comp_name` from `ledgerdetails` where (`ledgerdetails`.`ledger_id` = `d`.`transport_ledger_id`)), '') as `transport_name`,
    `s`.`tot_tcs_amt` as `tot_tcs_amt`,
    ifnull(`s`.`irn_no`, '') as `irn_no`,
    0 as `ledger_erning_deduction`,
    (
    select
        distinct `br`.`br_name`
    from
        (`mastertransaction` `m`
    join `branch` `br` on
        ((`br`.`br_id` = `m`.`br_id`)))
    where
        (`m`.`reference_no` = `s`.`invoice_no`)) as `acc_branch`,
    `s3`.`trans_id3` as `trans_id3`,
    ifnull(`l`.`contact1`, '') as `Cust_contactNo`,
    concat(ifnull(`l`.`fname`, ''), ' ', ifnull(`l`.`mname`, ''), ' ', ifnull(`l`.`lname`, '')) as `res_person_name`,
    ifnull((select `itemgroups`.`grp_nm` from `itemgroups` where (`itemgroups`.`grp_code` = `i`.`grp_code`)), '') as `item_group_nm`,
    ifnull((select `category`.`category` from `category` where (`category`.`category_id` = `i`.`category`)), '') as `item_category`,
    ifnull(`i`.`product_identity`, '') as `item_type`,
    (case
        when exists(
        select
            `ac`.`ledger_name`
        from
            ((`mastertransaction` `m`
        join `accounttransaction` `at` on
            ((`m`.`tr_id` = `at`.`tr_id`)))
        join `accountcreation` `ac` on
            (((`at`.`ledger_id` = `ac`.`ledger_id`)
                and (`ac`.`ledger_name` = 'discount sale'))))
        where
            (`m`.`reference_no` = `s`.`invoice_no`)) then ((((((`s3`.`quantity` - `s3`.`short`) - `s3`.`mortality`) - `s3`.`culls`) / (100 + `s3`.`discount`)) * `s3`.`discount`) * `s3`.`rate`)
        else 0
    end) as `discount_amt`,
    `g`.`group_name` as `group_name`,
    ifnull((select `at`.`area_name` from `areastatic` `at` where (`at`.`area_code` = `l`.`area_code`)), '-') as `area_name`,
    '' as `consignee`,
    '' as `consignee_contact_no`,
    '' as `consignee_addr`,
    ifnull(`ac`.`party_code`, '') as `party_code`,
    ifnull((select concat(`employee`.`fname`, ' ', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `l`.`emp_id`)), '-') as `emp_name`,
    ifnull((select concat(`employee`.`fname`, '', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `s`.`last_modified_by`)), '-') as `last_modified_by`,
    (
    select
        `projectmodules`.`module_name`
    from
        `projectmodules`
    where
        (`projectmodules`.`module_id` = `s`.`module_id`)) as `module_name`,
    0 as `gst_rate`,
    `u`.`govt_unit` as `govt_unit`,
    `s`.`is_reverse_charge` as `is_reverse_charge`,
    ifnull(`s`.`sale_scheme_remark`, '') as `sale_scheme_remark`,
    '' as `broker_id`,
    '' as `broker_name`,
    0 as `feed_distribution_amt`
from
    (((((((((((((((((((((((((`sale` `s`
join `accountcreation` `ac` on
    ((`ac`.`ledger_id` = `s`.`ledger_id`)))
join `groupcreation` `g` on
    ((`g`.`group_id` = `ac`.`group_id`)))
left join `transaddrdetails` `traddr` on
    ((`traddr`.`tradd_id` = `s`.`transid`)))
left join `consigneedetails` `cd` on
    ((`cd`.`consignee_id` = `traddr`.`consignee_id`)))
join `salestransactions1` `s1` on
    ((`s`.`invoice_no` = `s1`.`invoice_no`)))
join `hmschickssalestransactions2` `s2` on
    ((`s1`.`trans_id1` = `s2`.`trans_id1`)))
join `hmschickssalestransactions3` `s3` on
    ((`s3`.`trans_id2` = `s2`.`trans_id2`)))
left join `deliverynote` `dn` on
    ((`dn`.`tracking_no` = `s1`.`tracking_no`)))
join `stockin` `si` on
    ((`si`.`stock_id` = `s3`.`stock_id`)))
join `stockdetails` `sd` on
    ((`sd`.`stock_detail_id` = `si`.`stock_detail_id`)))
join `items` `i` on
    ((`i`.`i_code` = `sd`.`item_id`)))
join `branch` `br` on
    ((`br`.`br_id` = `si`.`branch_id`)))
join `address` `branchadr` on
    ((`branchadr`.`addr_id` = `br`.`addr_id`)))
join `state` `brstate` on
    ((`brstate`.`state_id` = `branchadr`.`state_id`)))
left join `ledgerdetails` `l` on
    ((`l`.`ledger_id` = `s`.`ledger_id`)))
left join `address` `ledadr` on
    ((`ledadr`.`addr_id` = `l`.`addr_id`)))
left join `state` `st` on
    ((`st`.`state_id` = `ledadr`.`state_id`)))
left join `city` `ct` on
    ((`ct`.`city_id` = `ledadr`.`city_id`)))
left join `bankdetails` `b` on
    ((`b`.`bank_id` = `l`.`bank_id`)))
join `vouchercreation` `v` on
    ((`v`.`voucher_id` = `s`.`voucher_id`)))
left join `vouchercreation` `vc` on
    ((`vc`.`voucher_id` = `v`.`voucher_type`)))
left join `salesorder` `slo` on
    ((`slo`.`order_no` = `s1`.`order_no`)))
left join `deliverynotetransact1` `dn1` on
    ((`dn1`.`tracking_no` = `s1`.`tracking_no`)))
left join `drivertransportrecord` `d` on
    ((`d`.`trans_id` = `s`.`transport`)))
join `units` `u` on
    ((`u`.`short_name` = `i`.`unit`)))
where
    ((`s`.`date` between '2023-01-01' and '2024-12-31')
        and (`s`.`module_id` = 3)
            and (not(exists(
            select
                distinct `birdsalestransactions3`.`trans_id3`
            from
                `birdsalestransactions3`
            where
                (`birdsalestransactions3`.`trans_id3` = `s3`.`trans_id3`))))
                and (not(exists(
                select
                    distinct `birdoutdetails`.`trans_id3`
                from
                    `birdoutdetails`
                where
                    (`birdoutdetails`.`trans_id3` = `s3`.`trans_id3`)))))
union
select
    distinct date_format(cast(`s`.`date` as date), '%d/%m/%Y') as `date`,
    date_format(cast(`s`.`date` as date), '%M - %Y') as `entrymonth`,
    `s`.`invoice_no` as `invoice_no`,
    ifnull(`s`.`reference_no`, '-') as `reference_no`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `s`.`ledger_id`)) as `ledger_name`,
    ifnull(`ledadr`.`addr_l1`, '-') as `address1`,
    ifnull(`ct`.`city_name`, '-') as `city_name`,
    ifnull(`st`.`state_name`, '-') as `party_state_name`,
    ifnull(`l`.`tan_no`, '-') as `tan_no`,
    ifnull(`l`.`sale_tax_no`, '-') as `sale_tax_no`,
    ifnull(`b`.`pan_no`, '-') as `pan_no`,
    `i`.`i_des` as `i_des`,
    `i`.`unit` as `unit`,
    ifnull(`bs3`.`bird_quantity`, 0) as `quantity`,
    round(`s3`.`quantity`, 2) as `weight`,
    round(`s3`.`rate`, 2) as `rate`,
    round(((`s3`.`quantity` * `s3`.`rate`) - (((`s3`.`quantity` * `s3`.`rate`) * ifnull(`s3`.`discount`, 0)) / 100)), 2) as `prod_value`,
    ifnull(`s3`.`vat_amount`, 0) as `vat_amount`,
    `s3`.`cst_amount` as `cst_amount`,
    `s3`.`cgst_amt` as `cgst_amt`,
    `s3`.`sgst_amt` as `sgst_amt`,
    `s3`.`igst_amt` as `igst_amt`,
    `s3`.`total_cost` as `total_cost`,
    `s`.`reference_id` as `reference_id`,
    `s`.`total_amt` as `bill_amt`,
    `s`.`ledger_id` as `ledger_id`,
    ifnull(`vc`.`voucher_name`, `v`.`voucher_name`) as `voucher_name`,
    `s`.`module_id` as `module_id`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `s`.`sale_ledger_id`)) as `CR_ledger_name`,
    ifnull((select `ledgerdetails`.`gstin_no` from `ledgerdetails` where ((`ledgerdetails`.`ledger_id` = `s`.`ledger_id`) and (`ledgerdetails`.`gst_registration_date` <= `s`.`date`))), '') as `Party_gstin_no`,
    ifnull(`i`.`hsn_code`, '') as `hsn_code`,
    '' as `tracking_no`,
    ifnull(`s`.`ewaybill_no`, '-') as `ewaybill_no`,
    ifnull(`s`.`narration`, '') as `narration`,
    `s3`.`discount` as `discount`,
    `s`.`deduction` as `deduction`,
    `br`.`br_name` as `br_name`,
    `br`.`gstin_no` as `branch_gstin_no`,
    `brstate`.`state_name` as `branch_state_name`,
    '' as `order_no`,
    ifnull(`s`.`delivery_type`, '') as `delivery_type`,
    0 as `halting_charges`,
    ifnull(`s`.`other_charges`, '') as `other_charges`,
    0 as `loading_charges`,
    0 as `freight_charges`,
    ifnull(`d`.`dri_name`, '') as `dri_name`,
    ifnull(`d`.`veh_no`, '') as `veh_no`,
    ifnull(`d`.`contact1`, '') as `contact_no`,
    ifnull((select `ledgerdetails`.`comp_name` from `ledgerdetails` where (`ledgerdetails`.`ledger_id` = `d`.`transport_ledger_id`)), '') as `transport_name`,
    `s`.`tot_tcs_amt` as `tot_tcs_amt`,
    ifnull(`s`.`irn_no`, '') as `irn_no`,
    0 as `ledger_erning_deduction`,
    (
    select
        distinct `br`.`br_name`
    from
        (`mastertransaction` `m`
    join `branch` `br` on
        ((`br`.`br_id` = `m`.`br_id`)))
    where
        (`m`.`reference_no` = `s`.`invoice_no`)) as `acc_branch`,
    `s3`.`trans_id3` as `trans_id3`,
    ifnull(`l`.`contact1`, '') as `Cust_contactNo`,
    concat(ifnull(`l`.`fname`, ''), ' ', ifnull(`l`.`mname`, ''), ' ', ifnull(`l`.`lname`, '')) as `res_person_name`,
    ifnull((select `itemgroups`.`grp_nm` from `itemgroups` where (`itemgroups`.`grp_code` = `i`.`grp_code`)), '') as `item_group_nm`,
    ifnull((select `category`.`category` from `category` where (`category`.`category_id` = `i`.`category`)), '') as `item_category`,
    ifnull(`i`.`product_identity`, '') as `item_type`,
    (((`s3`.`quantity` * `s3`.`rate`) * ifnull(`s3`.`discount`, 0)) / 100) as `discount_amt`,
    `g`.`group_name` as `group_name`,
    ifnull((select `at`.`area_name` from `areastatic` `at` where (`at`.`area_code` = `l`.`area_code`)), '-') as `area_name`,
    '' as `consignee`,
    '' as `consignee_contact_no`,
    '' as `consignee_addr`,
    ifnull(`ac`.`party_code`, '') as `party_code`,
    ifnull((select concat(`employee`.`fname`, ' ', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `l`.`emp_id`)), '-') as `emp_name`,
    ifnull((select concat(`employee`.`fname`, '', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `s`.`last_modified_by`)), '-') as `last_modified_by`,
    (
    select
        `projectmodules`.`module_name`
    from
        `projectmodules`
    where
        (`projectmodules`.`module_id` = `s`.`module_id`)) as `module_name`,
    0 as `gst_rate`,
    `u`.`govt_unit` as `govt_unit`,
    `s`.`is_reverse_charge` as `is_reverse_charge`,
    ifnull(`s`.`sale_scheme_remark`, '') as `sale_scheme_remark`,
    ifnull(`s`.`broker_id`, '') as `broker_id`,
    ifnull((select `accountcreation`.`ledger_name` from `accountcreation` where (`accountcreation`.`ledger_id` = `s`.`broker_id`)), '') as `broker_name`,
    0 as `feed_distribution_amt`
from
    ((((((((((((((((((((((((((`salestransactions3` `s3`
join `birdsalestransactions3` `bs3` on
    ((`bs3`.`trans_id3` = `s3`.`trans_id3`)))
join `birdoutdetails` `bo` on
    ((`bo`.`trans_id3` = `s3`.`trans_id3`)))
join `stockout` `so` on
    ((`so`.`out_id` = `bo`.`out_id`)))
join `stockin` `si` on
    ((`si`.`stock_id` = `so`.`stock_id`)))
join `branch` `br` on
    ((`br`.`br_id` = `si`.`branch_id`)))
join `address` `branchadr` on
    ((`branchadr`.`addr_id` = `br`.`addr_id`)))
join `state` `brstate` on
    ((`brstate`.`state_id` = `branchadr`.`state_id`)))
join `salestransactions2` `s2` on
    ((`s2`.`trans_id2` = `s3`.`trans_id2`)))
join `salestransactions1` `s1` on
    ((`s1`.`trans_id1` = `s2`.`trans_id1`)))
join `sale` `s` on
    ((`s`.`invoice_no` = `s1`.`invoice_no`)))
join `accountcreation` `ac` on
    ((`ac`.`ledger_id` = `s`.`ledger_id`)))
join `groupcreation` `g` on
    ((`g`.`group_id` = `ac`.`group_id`)))
left join `transaddrdetails` `traddr` on
    ((`traddr`.`tradd_id` = `s`.`transid`)))
left join `consigneedetails` `cd` on
    ((`cd`.`consignee_id` = `traddr`.`consignee_id`)))
left join `ledgerdetails` `l` on
    ((`l`.`ledger_id` = `s`.`ledger_id`)))
left join `address` `ledadr` on
    ((`ledadr`.`addr_id` = `l`.`addr_id`)))
join `stockdetails` `sd` on
    ((`sd`.`stock_detail_id` = `si`.`stock_detail_id`)))
join `items` `i` on
    ((`i`.`i_code` = `sd`.`item_id`)))
left join `state` `st` on
    ((`st`.`state_id` = `ledadr`.`state_id`)))
left join `city` `ct` on
    ((`ct`.`city_id` = `ledadr`.`city_id`)))
left join `bankdetails` `b` on
    ((`b`.`bank_id` = `l`.`bank_id`)))
join `vouchercreation` `v` on
    ((`v`.`voucher_id` = `s`.`voucher_id`)))
left join `vouchercreation` `vc` on
    ((`vc`.`voucher_id` = `v`.`voucher_type`)))
left join `salesorder` `slo` on
    ((`slo`.`order_no` = `s1`.`order_no`)))
left join `drivertransportrecord` `d` on
    ((`d`.`trans_id` = `s`.`transport`)))
left join `units` `u` on
    ((`u`.`short_name` = `i`.`unit`)))
where
    ((`bo`.`form_type` = 'S')
        and (`si`.`module_id` = '6')
            and (`s`.`date` between '2023-01-01' and '2024-12-31'))
group by
    `s3`.`trans_id3`
union
select
    distinct date_format(cast(`s`.`date` as date), '%d/%m/%Y') as `date`,
    date_format(cast(`s`.`date` as date), '%M - %Y') as `entrymonth`,
    `s`.`invoice_no` as `invoice_no`,
    ifnull(`s`.`reference_no`, '-') as `reference_no`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `s`.`ledger_id`)) as `ledger_name`,
    ifnull(`ledadr`.`addr_l1`, '-') as `address1`,
    ifnull(`ct`.`city_name`, '-') as `city_name`,
    ifnull(`st`.`state_name`, '-') as `party_state_name`,
    ifnull(`l`.`tan_no`, '-') as `tan_no`,
    ifnull(`l`.`sale_tax_no`, '-') as `sale_tax_no`,
    ifnull(`b`.`pan_no`, '-') as `pan_no`,
    `i`.`i_des` as `i_des`,
    `i`.`unit` as `unit`,
    `convert_qty_to_upper_unit`(`s3`.`quantity`,
    `i`.`i_code`) as `quantity`,
    round(`s3`.`weight`, 2) as `weight`,
    round(`get_rate`(`s3`.`rate`, `i`.`i_code`, `s3`.`unit_of_rate`), 2) as `rate`,
    if(((`s`.`module_id` = 10)
        and (`s3`.`bill_on` = 'WT')
            and (('a0200' = 'a0062')
                or ('a0200' = 'a0062_129'))),
    ((`s3`.`weight` * `s3`.`rate`) - (((`s3`.`weight` * `s3`.`rate`) * `s3`.`discount`) / 100)),
    ((`s3`.`quantity` * `s3`.`rate`) - (((`s3`.`quantity` * `s3`.`rate`) * `s3`.`discount`) / 100))) as `prod_value`,
    ifnull(`s3`.`vat_amount`, 0) as `vat_amount`,
    `s3`.`cst_amount` as `cst_amount`,
    `s3`.`cgst_amt` as `cgst_amt`,
    `s3`.`sgst_amt` as `sgst_amt`,
    `s3`.`igst_amt` as `igst_amt`,
    `s3`.`total_cost` as `total_cost`,
    `s`.`reference_id` as `reference_id`,
    `s`.`total_amt` as `bill_amt`,
    `s`.`ledger_id` as `ledger_id`,
    ifnull(`vc`.`voucher_name`, `v`.`voucher_name`) as `voucher_name`,
    `s`.`module_id` as `module_id`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `s`.`sale_ledger_id`)) as `CR_ledger_name`,
    ifnull((select `ledgerdetails`.`gstin_no` from `ledgerdetails` where ((`ledgerdetails`.`ledger_id` = `s`.`ledger_id`) and (`ledgerdetails`.`gst_registration_date` <= `s`.`date`))), '') as `Party_gstin_no`,
    ifnull(`i`.`hsn_code`, '') as `hsn_code`,
    ifnull(concat(`dn`.`reference_id`, ' (', convert(date_format(`dn`.`date`, '%d/%m/%y') using latin1), ')'), '') as `tracking_no`,
    ifnull(`s`.`ewaybill_no`, '-') as `ewaybill_no`,
    ifnull(`s`.`narration`, '') as `narration`,
    `s3`.`discount` as `discount`,
    `s`.`deduction` as `deduction`,
    `br`.`br_name` as `br_name`,
    `br`.`gstin_no` as `branch_gstin_no`,
    `brstate`.`state_name` as `branch_state_name`,
    ifnull(`slo`.`reference_id`,(select `salesorder`.`reference_id` from `salesorder` where (`salesorder`.`order_no` = `dn1`.`order_no`))) as `order_no`,
    ifnull(`s`.`delivery_type`, '') as `delivery_type`,
    ifnull(`s`.`halting_charges`, '') as `halting_charges`,
    ifnull(`s`.`other_charges`, '') as `other_charges`,
    ifnull(`s`.`loading_charges`, '') as `loading_charges`,
    ifnull((select `tr`.`amt` from `accounttransaction` `tr` where ((`tr`.`tr_id` = `s`.`fc_tr_id`) and (`tr`.`acc_type` = 'DR'))), 0) as `freight_charges`,
    ifnull(`d`.`dri_name`, '') as `dri_name`,
    ifnull(`d`.`veh_no`, '') as `veh_no`,
    ifnull(`d`.`contact1`, '') as `contact_no`,
    ifnull((select `ledgerdetails`.`comp_name` from `ledgerdetails` where (`ledgerdetails`.`ledger_id` = `d`.`transport_ledger_id`)), '') as `transport_name`,
    `s`.`tot_tcs_amt` as `tot_tcs_amt`,
    ifnull(`s`.`irn_no`, '') as `irn_no`,
    ifnull((select sum(`tr`.`disc_amount`) from ((`salediscountledger` `tr` join `accountcreation` `ac` on((`ac`.`ledger_id` = `tr`.`ledger_id`))) join `groupcreation` `g` on((`g`.`group_id` = `ac`.`group_id`))) where (`tr`.`invoice_no` = `s`.`invoice_no`)), 0) as `ledger_erning_deduction`,
    `mbr`.`br_name` as `acc_branch`,
    `s3`.`trans_id3` as `trans_id3`,
    ifnull(`l`.`contact1`, '') as `Cust_contactNo`,
    concat(ifnull(`l`.`fname`, ''), ' ', ifnull(`l`.`mname`, ''), ' ', ifnull(`l`.`lname`, '')) as `res_person_name`,
    ifnull((select `itemgroups`.`grp_nm` from `itemgroups` where (`itemgroups`.`grp_code` = `i`.`grp_code`)), '') as `item_group_nm`,
    ifnull((select `category`.`category` from `category` where (`category`.`category_id` = `i`.`category`)), '') as `item_category`,
    ifnull(`i`.`product_identity`, '') as `item_type`,
    if(((`s`.`module_id` = 10)
        and (`s3`.`bill_on` = 'WT')
            and (('a0200' = 'a0062')
                or ('a0200' = 'a0062_129'))),
    (((`s3`.`weight` * `s3`.`rate`) * `s3`.`discount`) / 100),
    (((`s3`.`quantity` * `s3`.`rate`) * `s3`.`discount`) / 100)) as `discount_amt`,
    `g`.`group_name` as `group_name`,
    ifnull((select `at`.`area_name` from `areastatic` `at` where (`at`.`area_code` = `l`.`area_code`)), '-') as `area_name`,
    ifnull(`cd`.`consignee_name`, '') as `consignee`,
    ifnull(`cd`.`contact_no`, '') as `consignee_contact_no`,
    ifnull(`cd`.`address`, '') as `consignee_addr`,
    ifnull(`ac`.`party_code`, '') as `party_code`,
    ifnull((select concat(`employee`.`fname`, ' ', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `l`.`emp_id`)), '-') as `emp_name`,
    ifnull((select concat(`employee`.`fname`, '', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `s`.`last_modified_by`)), '-') as `last_modified_by`,
    (
    select
        `projectmodules`.`module_name`
    from
        `projectmodules`
    where
        (`projectmodules`.`module_id` = `s`.`module_id`)) as `module_name`,
    ((`s3`.`cgst_percent` + `s3`.`sgst_percent`) + `s3`.`igst_percent`) as `gst_rate`,
    `u`.`govt_unit` as `govt_unit`,
    `s`.`is_reverse_charge` as `is_reverse_charge`,
    ifnull(`s`.`sale_scheme_remark`, '') as `sale_scheme_remark`,
    ifnull(`s`.`broker_id`, '') as `broker_id`,
    ifnull((select `accountcreation`.`ledger_name` from `accountcreation` where (`accountcreation`.`ledger_id` = `s`.`broker_id`)), '') as `broker_name`,
    ifnull((select `att`.`amt` from `accounttransaction` `att` where ((`att`.`tr_id` = `s`.`feed_distribution_jv`) and (`att`.`acc_type` = 'CR'))), 0) as `feed_distribution_amt`
from
    ((((((((((((((((((((((((((`salestransactions3` `s3`
join `salestransactions2` `s2` on
    ((`s2`.`trans_id2` = `s3`.`trans_id2`)))
join `salestransactions1` `s1` on
    ((`s1`.`trans_id1` = `s2`.`trans_id1`)))
join `sale` `s` on
    ((`s`.`invoice_no` = `s1`.`invoice_no`)))
join `accountcreation` `ac` on
    ((`ac`.`ledger_id` = `s`.`ledger_id`)))
join `groupcreation` `g` on
    ((`g`.`group_id` = `ac`.`group_id`)))
left join `transaddrdetails` `traddr` on
    ((`traddr`.`tradd_id` = `s`.`transid`)))
left join `consigneedetails` `cd` on
    ((`cd`.`consignee_id` = `traddr`.`consignee_id`)))
join `mastertransaction` `mt` on
    ((`mt`.`reference_no` = `s`.`invoice_no`)))
join `branch` `mbr` on
    ((`mbr`.`br_id` = `mt`.`br_id`)))
left join `deliverynote` `dn` on
    ((`dn`.`tracking_no` = `s1`.`tracking_no`)))
join `branch` `br` on
    ((`br`.`br_id` = `s`.`branch_id`)))
join `address` `branchadr` on
    ((`branchadr`.`addr_id` = `br`.`addr_id`)))
join `state` `brstate` on
    ((`brstate`.`state_id` = `branchadr`.`state_id`)))
left join `ledgerdetails` `l` on
    ((`l`.`ledger_id` = `s`.`ledger_id`)))
left join `address` `ledadr` on
    ((`ledadr`.`addr_id` = `l`.`addr_id`)))
join `items` `i` on
    ((`i`.`i_code` = `s2`.`item_id`)))
join `itemgroups` `ig` on
    ((`ig`.`grp_code` = `i`.`grp_code`)))
left join `state` `st` on
    ((`st`.`state_id` = `ledadr`.`state_id`)))
left join `city` `ct` on
    ((`ct`.`city_id` = `ledadr`.`city_id`)))
left join `bankdetails` `b` on
    ((`b`.`bank_id` = `l`.`bank_id`)))
join `vouchercreation` `v` on
    ((`v`.`voucher_id` = `s`.`voucher_id`)))
left join `vouchercreation` `vc` on
    ((`vc`.`voucher_id` = `v`.`voucher_type`)))
left join `salesorder` `slo` on
    ((`slo`.`order_no` = `s1`.`order_no`)))
left join `deliverynotetransact1` `dn1` on
    ((`dn1`.`tracking_no` = `s1`.`tracking_no`)))
left join `drivertransportrecord` `d` on
    ((`d`.`trans_id` = `s`.`transport`)))
join `units` `u` on
    ((`u`.`short_name` = `i`.`unit`)))
where
    ((`s`.`module_id` <> '1')
        and (`s`.`date` between '2023-01-01' and '2024-12-31')
            and (not(exists(
            select
                distinct `birdsalestransactions3`.`trans_id3`
            from
                `birdsalestransactions3`
            where
                (`birdsalestransactions3`.`trans_id3` = `s3`.`trans_id3`))))
                and (not(exists(
                select
                    distinct `birdoutdetails`.`trans_id3`
                from
                    `birdoutdetails`
                where
                    (`birdoutdetails`.`trans_id3` = `s3`.`trans_id3`))))
                    and (not(exists(
                    select
                        distinct `hmschickssalestransactions2`.`trans_id1`
                    from
                        `hmschickssalestransactions2`
                    where
                        (`hmschickssalestransactions2`.`trans_id1` = `s1`.`trans_id1`))))
                        and (not(exists(
                        select
                            distinct `eggsalestransactions2`.`trans_id1`
                        from
                            `eggsalestransactions2`
                        where
                            (`eggsalestransactions2`.`trans_id1` = `s1`.`trans_id1`)))))
group by
    `s3`.`trans_id3`
union
select
    distinct date_format(cast(`s`.`date` as date), '%d/%m/%Y') as `date`,
    date_format(cast(`s`.`date` as date), '%M - %Y') as `entrymonth`,
    `s`.`invoice_no` as `invoice_no`,
    ifnull(`s`.`reference_no`, '-') as `reference_no`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `s`.`ledger_id`)) as `ledger_name`,
    ifnull(`ledadr`.`addr_l1`, '-') as `address1`,
    ifnull(`ct`.`city_name`, '-') as `city_name`,
    ifnull(`st`.`state_name`, '-') as `party_state_name`,
    ifnull(`l`.`tan_no`, '-') as `tan_no`,
    ifnull(`l`.`sale_tax_no`, '-') as `sale_tax_no`,
    ifnull(`b`.`pan_no`, '-') as `pan_no`,
    `ac`.`ledger_name` as `i_des`,
    '' as `unit`,
    `s3`.`service_qty` as `quantity`,
    round(`s3`.`service_qty`, 2) as `weight`,
    `s3`.`service_rate` as `rate`,
    ((`s3`.`service_qty` * `s3`.`service_rate`) - (((`s3`.`service_qty` * `s3`.`service_rate`) * `s3`.`discount_per`) / 100)) as `prod_value`,
    ifnull(`s3`.`vat_amt`, 0) as `vat_amount`,
    0 as `cst_amount`,
    `s3`.`cgst_amt` as `cgst_amt`,
    `s3`.`sgst_amt` as `sgst_amt`,
    `s3`.`igst_amt` as `igst_amt`,
    `s3`.`net_amount` as `total_cost`,
    `s`.`reference_id` as `reference_id`,
    `s`.`total_amt` as `bill_amt`,
    `s`.`ledger_id` as `ledger_id`,
    ifnull(`vc`.`voucher_name`, `v`.`voucher_name`) as `voucher_name`,
    `s`.`module_id` as `module_id`,
    (
    select
        `accountcreation`.`ledger_name`
    from
        `accountcreation`
    where
        (`accountcreation`.`ledger_id` = `s`.`sale_ledger_id`)) as `CR_ledger_name`,
    ifnull((select `ledgerdetails`.`gstin_no` from `ledgerdetails` where ((`ledgerdetails`.`ledger_id` = `s`.`ledger_id`) and (`ledgerdetails`.`gst_registration_date` <= `s`.`date`))), '') as `Party_gstin_no`,
    `t`.`sac_code` as `hsn_code`,
    '' as `tracking_no`,
    ifnull(`s`.`ewaybill_no`, '-') as `ewaybill_no`,
    ifnull(`s`.`narration`, '') as `narration`,
    `s3`.`discount_per` as `discount`,
    `s`.`deduction` as `deduction`,
    `br`.`br_name` as `br_name`,
    `br`.`gstin_no` as `branch_gstin_no`,
    `brstate`.`state_name` as `branch_state_name`,
    '' as `order_no`,
    ifnull(`s`.`delivery_type`, '') as `delivery_type`,
    ifnull(`s`.`halting_charges`, '') as `halting_charges`,
    ifnull(`s`.`other_charges`, '') as `other_charges`,
    ifnull(`s`.`loading_charges`, '') as `loading_charges`,
    ifnull((select `tr`.`amt` from `accounttransaction` `tr` where ((`tr`.`tr_id` = `s`.`fc_tr_id`) and (`tr`.`acc_type` = 'DR'))), 0) as `freight_charges`,
    ifnull(`d`.`dri_name`, '') as `dri_name`,
    ifnull(`d`.`veh_no`, '') as `veh_no`,
    ifnull(`d`.`contact1`, '') as `contact_no`,
    ifnull((select `ledgerdetails`.`comp_name` from `ledgerdetails` where (`ledgerdetails`.`ledger_id` = `d`.`transport_ledger_id`)), '') as `transport_name`,
    `s`.`tot_tcs_amt` as `tot_tcs_amt`,
    ifnull(`s`.`irn_no`, '') as `irn_no`,
    ifnull((select sum(`tr`.`disc_amount`) from ((`salediscountledger` `tr` join `accountcreation` `ac` on((`ac`.`ledger_id` = `tr`.`ledger_id`))) join `groupcreation` `g` on((`g`.`group_id` = `ac`.`group_id`))) where (`tr`.`invoice_no` = `s`.`invoice_no`)), 0) as `ledger_erning_deduction`,
    (
    select
        distinct `br`.`br_name`
    from
        (`mastertransaction` `m`
    join `branch` `br` on
        ((`br`.`br_id` = `m`.`br_id`)))
    where
        (`m`.`reference_no` = `s`.`invoice_no`)) as `acc_branch`,
    '' as `trans_id3`,
    ifnull(`l`.`contact1`, '') as `Cust_contactNo`,
    concat(ifnull(`l`.`fname`, ''), ' ', ifnull(`l`.`mname`, ''), ' ', ifnull(`l`.`lname`, '')) as `res_person_name`,
    '' as `item_group_nm`,
    '' as `item_category`,
    '' as `item_type`,
    (((`s3`.`service_qty` * `s3`.`service_rate`) * `s3`.`discount_per`) / 100) as `discount`,
    `g`.`group_name` as `group_name`,
    ifnull((select `at`.`area_name` from `areastatic` `at` where (`at`.`area_code` = `l`.`area_code`)), '-') as `area_name`,
    ifnull(`cd`.`consignee_name`, '') as `consignee`,
    ifnull(`cd`.`contact_no`, '') as `consignee_contact_no`,
    ifnull(`cd`.`address`, '') as `consignee_addr`,
    ifnull(`a`.`party_code`, '') as `party_code`,
    ifnull((select concat(`employee`.`fname`, ' ', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `l`.`emp_id`)), '-') as `emp_name`,
    ifnull((select concat(`employee`.`fname`, '', `employee`.`lname`, '(', `employee`.`emp_id`, ')') from `employee` where (`employee`.`emp_id` = `s`.`last_modified_by`)), '-') as `last_modified_by`,
    (
    select
        `projectmodules`.`module_name`
    from
        `projectmodules`
    where
        (`projectmodules`.`module_id` = `s`.`module_id`)) as `module_name`,
    ((`s3`.`cgst_percent` + `s3`.`sgst_percent`) + `s3`.`igst_percent`) as `gst_rate`,
    'NOS' as `govt_unit`,
    `s`.`is_reverse_charge` as `is_reverse_charge`,
    ifnull(`s`.`sale_scheme_remark`, '') as `sale_scheme_remark`,
    ifnull(`s`.`broker_id`, '') as `broker_id`,
    ifnull((select `accountcreation`.`ledger_name` from `accountcreation` where (`accountcreation`.`ledger_id` = `s`.`broker_id`)), '') as `broker_name`,
    ifnull((select `att`.`amt` from `accounttransaction` `att` where ((`att`.`tr_id` = `s`.`feed_distribution_jv`) and (`att`.`acc_type` = 'CR'))), 0) as `feed_distribution_amt`
from
    ((((((((((((((((((`servicesale` `s3`
join `sale` `s` on
    ((`s`.`invoice_no` = `s3`.`invoice_no`)))
join `accountcreation` `a` on
    ((`a`.`ledger_id` = `s`.`ledger_id`)))
join `groupcreation` `g` on
    ((`g`.`group_id` = `a`.`group_id`)))
left join `transaddrdetails` `traddr` on
    ((`traddr`.`tradd_id` = `s`.`transid`)))
left join `consigneedetails` `cd` on
    ((`cd`.`consignee_id` = `traddr`.`consignee_id`)))
join `accountcreation` `ac` on
    ((`ac`.`ledger_id` = `s3`.`service_ledger_id`)))
join `tax_category` `t` on
    ((`t`.`tax_category_id` = `ac`.`tax_category_id`)))
join `branch` `br` on
    ((`br`.`br_id` = `s`.`branch_id`)))
join `address` `branchadr` on
    ((`branchadr`.`addr_id` = `br`.`addr_id`)))
join `state` `brstate` on
    ((`brstate`.`state_id` = `branchadr`.`state_id`)))
left join `ledgerdetails` `l` on
    ((`l`.`ledger_id` = `s`.`ledger_id`)))
left join `address` `ledadr` on
    ((`ledadr`.`addr_id` = `l`.`addr_id`)))
left join `state` `st` on
    ((`st`.`state_id` = `ledadr`.`state_id`)))
left join `city` `ct` on
    ((`ct`.`city_id` = `ledadr`.`city_id`)))
left join `bankdetails` `b` on
    ((`b`.`bank_id` = `l`.`bank_id`)))
join `vouchercreation` `v` on
    ((`v`.`voucher_id` = `s`.`voucher_id`)))
left join `vouchercreation` `vc` on
    ((`vc`.`voucher_id` = `v`.`voucher_type`)))
left join `drivertransportrecord` `d` on
    ((`d`.`trans_id` = `s`.`transport`)))
where
    (`s`.`date` between '2023-01-01' and '2024-12-31')
order by
    str_to_date(`date`,
    '%d/%m/%y'),
    `reference_id`