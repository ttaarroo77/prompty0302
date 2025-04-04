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
end 