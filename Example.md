# Prerequisites

1. ActiveRecord model with the status column
2. `closed_loop` gem installed

# Configuration

```Ruby
# app/lib/order_machine.rb

require 'closed_loop'

class OrderMachine < ClosedLoop::Machine::Instance
  class RoleResolver < ClosedLoop::Machine::RoleResolver
    def call
      if !user
        :system
      elsif user.role_admin?
        :admin
      elsif target.buyer == user
        :buyer
      end
    end
  end

  private

  def configure_all
    # Naming convention - "[PROCESS_NAME__]STATE[_SUB_STATE]"

    # Checkout > View cart state
    transition(role: :buyer, from: :cart__created, to: :cart__reviewed)
    transition(role: :buyer, from: :cart__reviewed, to: :cart__confirmed)

    # Checkout > Billing state
    transition(role: :buyer, from: :cart__confirmed, to: :billing_information__submitted)
    transition(role: :buyer, from: :billing_information__information_submitted, to: :payment__method_selected)

    # Checkout > Payment state
    transition(role: :buyer, from: :payment__method_selected, to: :payment__pending)
    transition(role: :system, from: :payment__pending, to: :payment__failed)
    transition(role: :system, from: :payment__pending, to: :payment__confirmed)

    # Shipping
    transition(role: :admin, from: :payment__confirmed, to: :parcel__pending)
    transition(role: :admin, from: :parcel__pending, to: :parcel__prepared)
    transition(role: :admin, from: :parcel__prepared, to: :parcel__shipping_pending)
    transition(role: :system, from: :parcel__shipping_pending, to: :parcel__shipped)
    transition(role: :buyer, from: :parcel__shipped, to: :parcel__received)
    transition(role: :buyer, from: :parcel__shipped, to: :parcel__lost)

    # Shipping failed
    transition(role: :admin, from: :parcel__lost, to: :parcel__pending)

    transition(role: :admin, from: :parcel__lost, to: :refunded) do |target, _user|
      SendRefundNotification.call(target)
    end

    constraint(role: :admin, from: :parcel__lost, to: :parcel__pending) do |target, _user|
      # Only small size purchases could be reshipped
      target.total_price < 15.00
    end

    # Re-usable callbacks extracted from transitions
    callback(from: :parcel__shipped, to: %i[parcel__lost parcel__received]) do |target, _user|
      # Push slack notifications on shipping status change 
      PushOrderStatusSlackNotification.call(target)
    end

    callback(to: %i[payment__confirmed payment__failed]) do |target, _user|
      SendPaymentStatusNotification.call(target)
    end
  end
end
```

```Ruby
# In controller / service / interactor / background worker

OrderMachine.insantce.transition!(order, current_user, to: :parcel__received)

# invoke extra methods in the the same transition & ActiveRecord transaction: 

OrderMachine.insantce.transition!(order, current_user, to: :parcel__received) do
  order.items.each { |item| '#...' }
end

```