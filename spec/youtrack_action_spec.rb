describe Fastlane::Actions::YoutrackAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The youtrack plugin is working!")

      Fastlane::Actions::YoutrackAction.run(nil)
    end
  end
end
