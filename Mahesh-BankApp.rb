require 'sqlite3'
class Customer
    @@db = SQLite3::Database.new 'customers'
    @@db.execute("create table if not exists customers (Id integer,Acc_Number integer,Name text,DOB text,Address text,Acc_Type text,ATM_Pin integer,Acc_Balance integer);")
    @@default_acc_num = 504003000
    @result_keys = []
    @result_values = []
    def initialize()
        max_id = @@db.execute("select coalesce(max(id),1000) from customers;").flatten.first.to_i 
        @c_id = max_id + 1
        @c_acc_num = @@default_acc_num + @c_id
    end

    def self.all_customer_data()
        data = @@db.execute("select * from customers;").map{|i| i[0]}.to_a
        return data.size
    end
    
    def self.database_keys()
        keys = @@db.execute("PRAGMA table_info(customers);").map{|i| i[1]}
        return keys
    end

    def self.alter_customer_balance_db(user_input_acc,new_value)
        @@db.execute("update customers set Acc_Balance=#{new_value} where Acc_Number=#{user_input_acc}")
        result = customer_database(user_input_acc)
        return result
    end

    def self.alter_customer_atm_db(user_input_acc,new_value)
        @@db.execute("update customers set ATM_Pin=#{new_value} where Acc_Number=#{user_input_acc}")
        result = customer_database(user_input_acc)
        return result
    end

    def self.delete_customre_db(user_input_acc)
        @@db.execute("delete from customers where Acc_Number=#{user_input_acc}")
    end

    def self.customer_database(user_input_acc)
        specific_customer_data = Hash.new()
        keys = database_keys()
        values = @@db.execute("select * from customers where Acc_Number='#{user_input_acc}';").flatten.to_a
        if values.empty?
            puts "No data found for Account number: #{user_input_acc}......!"
            exit
        else
            keys.each_with_index do |key,index|
                specific_customer_data.merge!(key => values[index]) 
            end
            return specific_customer_data
        end
    end

    def registration()
        customer_data = Hash.new()
        puts "Thanks for choosing our bank to maintain your account ".center(150, '-*-')
        puts "Enter the following details:"
        puts "Enter your firstname: "
        first_name = gets.chomp.to_s
        puts "Enter your lastname: "
        last_name = gets.chomp.to_s
        c_name = first_name + last_name
        puts "Enter your DOB: \  ""[DD-MM-YY]"
        c_dob = gets.chomp.to_s
        puts "Enter your Permanent address: "
        c_address = gets.chomp.to_s
        puts "Provide account type either Savings or Salary? "
        c_acc_type = gets.chomp.to_s
        puts "Enter 4 digit PIN for your ATM card: "
        user_input_pin = gets.chomp
        if (user_input_pin.match?(/^\d{4}$/) && user_input_pin != 0000)
            atm_pin = user_input_pin.to_i
        else
            puts "Invalid ATM number...! So please try again to register with valid data."
            exit
        end
        puts "Enter the amount you would like to deposit: "
        deposit_amout = gets.chomp.to_i
        customer_data[@c_id] = {:Name => c_name, :Acc_Number => @c_acc_num, :DOB => c_dob, :Address => c_address, :Account_Type => c_acc_type, :ATM_Pin => atm_pin, :Acc_Balance => deposit_amout }
        result = @@db.execute("insert into customers (Id,Acc_Number,Name,DOB,Address,Acc_Type,ATM_Pin,Acc_Balance) values (#{@c_id},#{@c_acc_num},'#{customer_data[@c_id][:Name]}','#{customer_data[@c_id][:DOB]}','#{customer_data[@c_id][:Address]}','#{customer_data[@c_id][:Account_Type]}','#{customer_data[@c_id][:ATM_Pin]}','#{customer_data[@c_id][:Acc_Balance]}');")
        return customer_data
    end

    def self.display_account_details(user_input_acc)
        specific_customer_data = Hash.new()
        specific_customer_data = customer_database(user_input_acc)
        puts "Customer Details For Account Holder #{specific_customer_data["Name"]} is : ".center(150,'-*-')
        puts " "
        specific_customer_data.each do |key,value|
            if key == "ATM_Pin"
                puts "#{key} => ****"
            else
                puts "#{key} => #{value}"
            end
        end
    end

    def self.display_amount(user_input_acc)
        specific_customer_data = Hash.new()
        specific_customer_data = customer_database(user_input_acc)
        if specific_customer_data["Acc_Balance"].to_i >= 1000
            puts "Account Balance For Customer #{specific_customer_data["Name"]} is : #{specific_customer_data["Acc_Balance"]}"
        else
            puts "Account Balance For Customer #{specific_customer_data["Name"]} is : #{specific_customer_data["Acc_Balance"]}"
            puts "Please Maintain Minimum Balance As 1000 Rupees To Avoid Additional Charges, Thanks"
        end
    end

    def self.credit_amount(user_input_acc)
        specific_customer_data = Hash.new()
        specific_customer_data = customer_database(user_input_acc)
        puts "Enter The Amount, You Want To Credit In Your Account: "
        credit = gets.chomp.to_i
        puts " "
        current_balance = specific_customer_data["Acc_Balance"].to_i
        puts "#{specific_customer_data["Name"]}, Current Balance in your account is #{current_balance} "
        new_balance = credit + current_balance
        puts " "
        puts "#{specific_customer_data["Name"]}, #{credit} is credited in your account"
        specific_customer_data = alter_customer_balance_db(user_input_acc,new_balance)
        puts " "
        puts "Your available Balance is:  #{specific_customer_data["Acc_Balance"]} ".center(100,'=*=')
    end

    def self.debit_amount(user_input_acc)
        specific_customer_data = Hash.new()
        specific_customer_data = customer_database(user_input_acc)
        puts "Enter The Amount, You Want To Debit From Your Account: "
        debit = gets.chomp.to_i
        puts " "
        current_balance = specific_customer_data["Acc_Balance"].to_i
        puts "#{specific_customer_data["Name"]}, Current Balance in your account is #{current_balance} "
        case 
        when current_balance > 1000 then
            if (current_balance > 0 && current_balance >= debit) 
                new_balance = current_balance - debit      
            puts "#{specific_customer_data["Name"]}, #{debit} is debited from your account"
            puts " "
            specific_customer_data = alter_customer_balance_db(user_input_acc,new_balance)
            puts "Your available Balance is:  #{specific_customer_data["Acc_Balance"]} ".center(150,'=*=')
            puts " "
            end     
        when current_balance <= 1000 then
            puts "You only have the minimum balance as <= 1000, so if you debit the amount, pls maintain minimum balance ASAP. "
            puts " "
            if (current_balance > 0 && current_balance >= debit) 
                new_balance = current_balance - debit
            puts "#{specific_customer_data["Name"]}, #{debit} debited from your account"
            puts " "
            specific_customer_data = alter_customer_balance_db(user_input_acc,new_balance) 
            puts "Your available Balance is:  #{specific_customer_data["Acc_Balance"]} ".center(150,'=*=')
            end
        when current_balance < 1
            puts "You don't have sufficient amount to debit from your account....! "
        else
            puts "Invalid Input, Pls try again...! "
        end
    end

    def self.change_ATM_pin(user_input_acc)
        specific_customer_data = Hash.new()
        specific_customer_data = customer_database(user_input_acc)
        puts "Hi, #{specific_customer_data["Name"]} your current ATM_PIN is: #{specific_customer_data["ATM_Pin"]}"
        puts "Enter a new ATM_PIN number: "
        new_value = gets.chomp
        if (new_value.match?(/^\d{4}$/) && new_value != 0000)
            new_atm_pin = new_value.to_i
            specific_customer_data = alter_customer_atm_db(user_input_acc,new_atm_pin)
            puts "Your ATM_PIN is changed"
            puts " "
            puts "Hi, #{specific_customer_data["Name"]} your new ATM_PIN is: #{specific_customer_data["ATM_Pin"]}".center(105,'-*-')
        else
            puts "Invalid ATM number...! So please try again to change your ATM PIN."
            exit
        end
    end

    def self.total_accounts()
        counts = all_customer_data()
        puts "Total number of customers in our Bank is: #{counts}"
    end

    def self.delete_account(user_input_acc)
        specific_customer_data = Hash.new()
        specific_customer_data = customer_database(user_input_acc)
        puts "Hi #{specific_customer_data["Name"]}, would you like to delete your account?\n"
        puts "1. Delete\n2. Don't delete\n"
        user_choice = gets.chomp.to_i
        if user_choice == 1
            delete_customre_db(user_input_acc)
            puts "Hi #{specific_customer_data["Name"]}, Your account has been successfully deleted from our bank. Thanks for having your account with us."
        else
            puts "Hi #{specific_customer_data["Name"]}, Thanks for statying with us and we'll give the best service to our customers. "
        end
    end

    def self.existing_customer()
        specific_customer_data = Hash.new()
        puts "Enter acc to fetch your account details: "
        user_input_acc = gets.chomp.to_i
        specific_customer_data = customer_database(user_input_acc)
        if specific_customer_data.value?(user_input_acc)
            puts " "
            puts " "
            puts "Hi #{specific_customer_data["Name"]} , Your Account Details Are Verified. How Can We help?"
            puts " "
            puts " "
            puts "Hi #{specific_customer_data["Name"]} , Please Find The Following Services. ".center(150,'-*-')
            puts " "
            puts "1.  To display Account details\n2.  To display amount in your account\n3.  To credit amount\n4.  To debit amount\n5.  To change ATM pin number\n6.  Total Customers\n7.  To delete account\n8.  To quit"
            choice = gets.chomp.to_i
            case choice
            when 1 then
                display_account_details(user_input_acc)
            when 2 then
                display_amount(user_input_acc)
            when 3 then
                credit_amount(user_input_acc)
            when 4 then
                debit_amount(user_input_acc)
            when 5 then
                change_ATM_pin(user_input_acc)
            when 6 then
                total_accounts()
            when 7 then
                delete_account(user_input_acc)
            when 8 then
                puts "Thank You #{specific_customer_data["Name"]}..! Please Visit Again."
                exit
            else
                puts "Invalid Input....! Please Try Again."
            end
        else
            puts "Invalid account number....!"
        end
    end
end


puts "  Welcome to Maheshs Bank:  ".center(150,"-*-")
loop do
    puts " "
    puts " "
    puts "Please select the following options: "
    puts "  1.  New User\n  2.  Existing Customer\n  3.  Continue\n  4.  Quit\n"
    user_input = gets.chomp.to_i
    case user_input
    when 1 then
        c1 = Customer.new()
        customer_data = c1.registration()
        puts "Entered Customer Data Is: ".center(150, '-*-')
        customer_data.each do |key,value|
            puts "Customer ID is : #{key} "
            value.each do |subkey,subvalue|
            if subkey == :ATM_Pin
                puts "#{subkey} => ****"
            else
                puts "#{subkey} => #{subvalue}"
            end
            end
        end
    when 2 then
        Customer.existing_customer()
    when 3 then
        puts "You Selected Continue Option. Please Look For The Existing Service."
        next
    when 4 then
        puts "Thank You. Please Visit Again....!"
        break
    end
end
