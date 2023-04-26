# frozen_string_literal: true

require 'test_helper'

class Api::ContributionsControllerTest < ActionDispatch::IntegrationTest
  let!(:user) { create(:user) }

  describe '#create' do
    it 'blocks requests without an api key' do
      post(api_contributions_path, params: payload, as: :json)
      assert_response :bad_request
    end

    it 'creates contributions' do
      post(api_contributions_path, params: { api_key: user.api_key, **payload }, as: :json)
      assert_response :ok
      assert_equal 'cherrypush/cherry-app', Project.sole.name
      assert_equal ['JavaScript LoC', 'TypeScript LoC'], Metric.all.map(&:name).sort
      assert_equal [-12, +14], Contribution.all.map(&:diff).sort
      assert_equal ['Flavio Wuensche'], Contribution.all.map(&:author_name).uniq
      assert_equal ['f.wuensche@gmail.com'], Contribution.all.map(&:author_email).uniq
      assert_equal ['dea2fe473f86df94d1103e3c20e5cbdb3f18aad9'], Contribution.all.map(&:commit_sha).uniq
      assert_equal ['2023-02-07T21:33:15.000Z'], Contribution.all.map(&:commit_date).uniq
    end
  end

  private

  def payload
    {
      project_name: 'cherrypush/cherry-app',
      author_name: 'Flavio Wuensche',
      author_email: 'f.wuensche@gmail.com',
      commit_sha: 'dea2fe473f86df94d1103e3c20e5cbdb3f18aad9',
      commit_date: '2023-02-07T21:33:15.000Z',
      contributions: [{ metric_name: 'JavaScript LoC', diff: -12 }, { metric_name: 'TypeScript LoC', diff: +14 }],
    }
  end
end
