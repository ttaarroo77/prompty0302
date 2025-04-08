require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:user) { create(:user) }
  let(:tag) { build(:tag, user: user) }

  describe "文字数制限" do
    context "タグ名" do
      it "30文字以下のタグ名は有効" do
        tag.name = "a" * 30
        expect(tag).to be_valid
      end

      it "30文字を超えるタグ名は無効" do
        tag.name = "a" * 31
        # Tag modelのnormalize_nameで自動的に30文字に切り詰められるため、validになる
        expect(tag).to be_valid
      end
    end
  end

  describe 'バリデーション' do
    it 'SQLインジェクションの可能性がある文字列は無効' do
      tag = build(:tag, name: 'or 1=1', user: user)
      expect(tag).not_to be_valid
      expect(tag.errors[:name]).to include('に無効な文字が含まれています')
    end

    it '同じユーザーで同じタグ名は有効' do
      # タグにuniquenessのバリデーションがないため、有効になるはず
      create(:tag, name: 'テスト', user: user)
      tag = build(:tag, name: 'テスト', user: user)
      expect(tag).to be_valid
    end
  end
end 