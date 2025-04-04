require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:tag) { build(:tag) }

  describe "文字数制限" do
    context "タグ名" do
      it "30文字以下のタグ名は有効" do
        tag.name = "a" * 30
        expect(tag).to be_valid
      end

      it "30文字を超えるタグ名は無効" do
        tag.name = "a" * 31
        expect(tag).not_to be_valid
        expect(tag.errors[:name]).to include("は30文字以内で入力してください")
      end
    end
  end

  describe 'バリデーション' do
    let(:user) { create(:user) }
    let(:prompt) { create(:prompt, user: user) }

    it 'タグ名が50文字を超える場合は無効' do
      tag = build(:tag, name: 'a' * 51, user: user, prompt: prompt)
      expect(tag).not_to be_valid
      expect(tag.errors[:name]).to include('は50文字以内で入力してください')
    end

    it 'SQLインジェクションの可能性がある文字列は無効' do
      tag = build(:tag, name: 'or 1=1', user: user, prompt: prompt)
      expect(tag).not_to be_valid
      expect(tag.errors[:name]).to include('に無効な文字が含まれています')
    end

    it '同じプロンプト内で同じタグ名は無効' do
      create(:tag, name: 'テスト', user: user, prompt: prompt)
      tag = build(:tag, name: 'テスト', user: user, prompt: prompt)
      expect(tag).not_to be_valid
      expect(tag.errors[:name]).to include('は既に存在します')
    end
  end
end 