WITH 
	bean_supplier as (
		select
			sbt.id,
			s.id as supplier_id,
			s.name as supplier_name,
			bt.name as bean_type_name,
			sbt.updated_at
		from supplier_bean_type sbt
		left join supplier s
		on sbt.supplier_id = s.id
		left join bean_type bt
		on sbt.bean_type_id = bt.id
		order by sbt.id
	),
	bean_carrier as (
		select
			cb.id,
			c.name as carrier_name,
			d.id as driver_id,
			d.name as driver_name,
			b.name as bean_type_name,
			cb.updated_at
		from carrier_bean_type cb
		left join carrier c
		on cb.carrier_id = c.id
		left join driver d
		on d.carrier_id = c.id
		left join bean_type b
		on cb.bean_type_id = b.id
		order by cb.id
	),
	deliveries as (
		select
		d.id as delivery_id,
		d.supplier_id,
		bs.supplier_name,
		bs.bean_type_name as supplier_bean_type,
		bc.driver_name,
		bc.carrier_name,
		bc.bean_type_name as carrier_bean_type,
		case 
			when bs.bean_type_name = bc.bean_type_name then 1 else 0
		end as valid_delivery
		from delivery d
		left join bean_supplier bs
		on d.supplier_id = bs.supplier_id
		left join bean_carrier bc
		on d.driver_id = bc.driver_id
		order by delivery_id, supplier_bean_type
	)
	select
	delivery_id,
	supplier_name,
	sum(valid_delivery)
	from deliveries
	group by
		delivery_id,
		supplier_name
	having sum(valid_delivery) = 0
;