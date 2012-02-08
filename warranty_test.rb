#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'openssl'
require 'json'
require 'date'
require 'sinatra'

before do
  content_type :txt
end

not_found do
  "dang, you can't get there from here."
end

get '/:serial' do
  s = params[:serial]
  
  
    warranty_data = {}
    raw_data = open('https://selfsolve.apple.com/warrantyChecker.do?sn=' + s.upcase + '&country=USA')
    warranty_data = JSON.parse(raw_data.string[5..-2])

   @serial = "#{warranty_data['SERIAL_ID']}"
   @product = "#{warranty_data['PROD_DESCR']}"
   @purchase = "#{warranty_data['PURCHASE_DATE'].to_s.gsub("-",".")}"

    if warranty_data['COV_END_DATE'].empty? and warranty_data['HW_END_DATE']
      date = Date.parse(warranty_data['HW_END_DATE'])
      end_date = date.year.to_s + '.' + date.month.to_s + '.' + date.day.to_s
       @coverage = "#{end_date}"
    elsif warranty_data['COV_END_DATE'].empty?
      @coverage = "EXPIRED"
    else
      @coverage = "#{warranty_data['COV_END_DATE'].gsub("-",".")}"
    end
    
    erb :warranty_view
  end