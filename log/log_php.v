// Copyright 2022, Tanguy Salmon. All rights reserved.
// MIT license, please check LICENSE file.

module log

import os
import time

pub struct Phprow {
pub mut:
	date      time.Time
	host_name string
	state     string
	@in       string
	out       string
	mac       string
	src       string
	dst       string
	len       int
	tos       string
	prec      string
	ttl       int
	id        int
	proto     int
}

pub fn api_php_log_count() map[string]int {
	mut count := map[string]int{}
	res := os.execute_or_panic('cat /home/tanguy/logs/ufw.light.log | wc -l')
	count['count'] = res.output.int()
	return count
}

pub fn api_php_log_column() map[string]string {
	mut ufw_log := map[string]string{}
	ufw_log['date'] = 'Date'
	ufw_log['host_name'] = 'Host Name'
	ufw_log['state'] = 'State'
	ufw_log['in'] = 'In'
	ufw_log['out'] = 'Out'
	ufw_log['mac'] = 'Mac'
	ufw_log['src'] = 'Src'
	ufw_log['dst'] = 'Dst'
	ufw_log['len'] = 'Len'
	ufw_log['tos'] = 'Tos'
	ufw_log['prec'] = 'Prec'
	ufw_log['ttl'] = 'Ttl'
	ufw_log['id'] = 'Id'
	ufw_log['proto'] = 'Proto'

	return ufw_log
}

pub fn api_php_log_php() []Ufwrow {
	return api_php_log()
}

pub fn api_php_log() []Ufwrow {
	raw_list := os.execute_or_panic('cat ' + '/home/tanguy/logs/ufw.light.log')
	mut list := []Ufwrow{}

	for line in raw_list.output.split_into_lines() {
		splitted := line.split(' ')
		// param := line.split('] ')

		mut result := Ufwrow{
			date: parse_date(line)
			host_name: splitted[4]
			state: splitted[7] + ' ' + splitted[8]
		}

		for attr in line.split(' ') {
			if !attr.contains('=') {
				continue
			}

			val := attr.split('=')
			vall := val[0].to_lower()
			$for field in Ufwrow.fields {
				$if field.typ is string {
					if field.name == vall {
						result.$(field.name) = val[1]
						continue
					}
				}
				$if field.typ is int {
					if field.name == vall {
						result.$(field.name) = val[1].int()
						continue
					}
				}
			}
		}
		list << result
	}

	return list.filter(it.src.contains('192.168.1.34'))
}
