# encoding: utf-8
require_relative "../spec_helper"
require "logstash/plugin"
require "logstash/event"

describe LogStash::Filters::Sleep do

  let(:time) { 1 }
  subject { LogStash::Filters::Sleep.new("time" => time) }

  let(:properties) { {:name => "foo"} }
  let(:event)      { LogStash::Event.new(properties) }

  it "should register without errors" do
    plugin = LogStash::Plugin.lookup("filter", "sleep").new("time" => time)
    expect { plugin.register }.to_not raise_error
  end

  describe "sleep for a given time" do

    let(:time) { 5 }

    before(:each) do
      subject.register
    end

    it "should sleep for N seconds and continue" do
      expect(subject).to receive(:sleep).with(5)
      subject.filter(event)
    end

    context "when using every N events" do

      let(:messages) { 20 }
      let(:every) { 5 }
      subject { LogStash::Filters::Sleep.new("time" => time, "every" => every ) }

      before(:each) do
        subject.register
      end

      it "should sleep for N seconds and continue" do
        expect(subject).to receive(:sleep).with(5).exactly(4).times
        messages.times do
          subject.filter(event)
        end
      end

    end

   context "when using replay mode" do

      let(:messages) { 20 }
      subject { LogStash::Filters::Sleep.new("time" => time, "replay" => true ) }

      before(:each) do
        subject.register
      end

      it "should sleep for N seconds and continue" do
        expect(subject).to receive(:sleep).with(0.2).exactly(19).times
        messages.times do
          event.timestamp = event.timestamp + 1
          subject.filter(event)
        end
      end

    end
  end

  describe "sleep for a event-based time" do

    let(:time) { "%{time}" }

    before(:each) do
      subject.register
      event["time"] = 4
    end

    it "should sleep for N seconds and continue" do
      expect(subject).to receive(:sleep).with(4)
      subject.filter(event)
    end

    context "when using every N events" do

      let(:messages) { 20 }
      let(:every) { 5 }
      subject { LogStash::Filters::Sleep.new("time" => time, "every" => every ) }

      before(:each) do
        subject.register
      end

      it "should sleep for N seconds and continue" do
        expect(subject).to receive(:sleep).with(5).exactly(1).times
        expect(subject).to receive(:sleep).with(10).exactly(1).times
        expect(subject).to receive(:sleep).with(15).exactly(1).times
        expect(subject).to receive(:sleep).with(20).exactly(1).times
        messages.times do |i|
          event["time"] = i+1
          subject.filter(event)
        end
      end

    end

    context "when using replay mode" do

      let(:messages) { 20 }
      subject { LogStash::Filters::Sleep.new("time" => time, "replay" => true ) }

      before(:each) do
        subject.register
        event["time"] = 4
      end

      it "should sleep for N seconds and continue" do
        expect(subject).to receive(:sleep).with(0.25).exactly(19).times
        messages.times do
          event.timestamp = event.timestamp + 1
          subject.filter(event)
        end
      end

    end
  end
end
