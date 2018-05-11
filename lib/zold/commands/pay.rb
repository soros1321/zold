# Copyright (c) 2018 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'slop'
require_relative '../log.rb'

# PAY command.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2018 Yegor Bugayenko
# License:: MIT
module Zold
  # Money sending command
  class Pay
    def initialize(payer:, receiver:, amount:,
      pvtkey:, details: '-', log: Log::Quiet.new)
      @payer = payer
      @receiver = receiver
      @amount = amount
      @pvtkey = pvtkey
      @details = details
      @log = log
    end

    def run(args = [])
      opts = Slop.parse(args) do |o|
        o.bool '--force', 'Ignore all validations'
      end
      unless opts['force']
        raise "The amount can't be negative: #{@amount}" if @amount.negative?
        raise "Payer and receiver are equal: #{@payer}" if @payer == @receiver
        if !@payer.root? && @payer.balance < @amount
          raise "There is not enough funds in #{@payer} to send #{@amount}, \
  only #{@payer.balance} left"
        end
      end
      txn = @payer.sub(@amount, @receiver.id, @pvtkey, @details)
      @receiver.add(txn)
      @log.info("#{@amount} sent from #{@payer} to #{@receiver}: #{@details}")
      txn
    end
  end
end
