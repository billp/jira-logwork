# Copyright © 2020-2021. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in the
# Software without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies
# or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FIESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
# FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require "rspec"
require "configuration/configuration_manager"
require "configuration/shift_configuration"
require "constants"

describe Configuration do
  describe Configuration::ShiftConfiguration do
    describe "shift_duration" do
      it "raise configuration value not found exception" do
        conf = Configuration::ShiftConfiguration.new
        expect { conf.shift_duration }
          .to raise_error(LogworkException::ConfigurationValueNotFound)

        conf.update_shift_end("13:00")

        expect { conf.shift_duration }
          .to raise_error(LogworkException::ConfigurationValueNotFound)
      end

      it "return correct shift_duration" do
        conf = Configuration::ShiftConfiguration.new
        conf.update_shift_start("10:00")
        conf.update_shift_end("18:00")

        expect(conf.shift_duration).to be(8)
      end

      it "raise invalid shift hours duration" do
        conf = Configuration::ShiftConfiguration.new
        conf.update_shift_start("18:00")
        conf.update_shift_end("05:00")

        expect { conf.shift_duration }
          .to raise_error(LogworkException::InvalidShiftHoursDuration)
      end
    end
  end

  describe "shift_start" do
    it "raise configuration value not found exception" do
      allow(Configuration::ConfigurationManager.instance).to receive(:configuration_data).and_return({})
      conf = Configuration::ShiftConfiguration.new

      expect { conf.shift_start }
        .to raise_error(LogworkException::ConfigurationValueNotFound)
    end

    it "return shift start" do
      conf = Configuration::ShiftConfiguration.new
      conf.update_shift_start("10:12")
      expect(conf.shift_start).to eq("10:12")
    end
  end
end
