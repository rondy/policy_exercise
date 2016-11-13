require 'rails_helper'

describe PresentFailedPermissionForProjectCreation do
  it 'presents a message when user must be a manager' do
    message = described_class.new.call(:user_must_be_a_manager)
    expect(message).to eq('User must be a manager')
  end

  it 'presents a message when user must be within the projects count limit rule' do
    message = described_class.new.call(:user_must_be_within_the_projects_count_limit_rule)
    expect(message).to eq('User can only create 5 projects')
  end

  it 'presents a message when project creation config must be no blocked' do
    message = described_class.new.call(:project_creation_config_must_be_no_blocked)
    expect(message).to eq('The project creation config is blocked for this user')
  end

  it 'presents nothing when no error reason is given' do
    message = described_class.new.call(nil)
    expect(message).to eq('')
  end
end
