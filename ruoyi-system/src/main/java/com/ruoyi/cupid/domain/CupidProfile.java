package com.ruoyi.cupid.domain;

import java.util.Date;
import java.util.List;

/**
 * Cupid Match 用户资料 cm_profiles
 */
public class CupidProfile
{
    private String id;
    private String profileType;
    private String gender;
    private int birthYear;
    private int height;
    private String cityCode;
    private String countryCode;
    private String nationalityCode;
    private String profileStatus;
    private Date lastActiveAt;
    private boolean familyVisible;
    private String degreeLevel;
    private String educationCode;
    private String industryCode;
    private String maritalStatus;
    private boolean hasChildren;
    private String childrenPlan;
    private boolean acceptsLongDistance;
    private String datingIntentionCode;
    private String relocation;
    private int preferredAgeMin;
    private int preferredAgeMax;
    private String preferredLocation;
    private String smoking;
    private String drinking;
    private String activityLevel;
    private String weekendStyle;
    private String pets;
    private String communicationStyle;
    private Date archivedAt;
    private Date createdAt;
    private Date updatedAt;

    /** 目录查询参数（非表字段） */
    private Integer page;
    private Integer ageMin;
    private Integer ageMax;
    private Integer heightMin;
    private Integer heightMax;
    private String language;
    private String sort;
    private String familyMode;
    private String locale;
    private String viewerUserId;
    private Boolean hasChildrenFilter;
    private Boolean acceptsLongDistanceFilter;
    private int pageSize;
    private int offset;
    private String verified;
    private int count;

    /** service 关联结果 */
    private List<CupidProfilePhoto> photos;
    private int age;
    private List<String> languages;
    private String displayName;
    private String avatarUrl;
    private String city;
    private String education;
    private String industry;
    private String datingIntentionLabel;
    private String summary;
    private List<String> tags;
    private List<String> relationshipValues;
    private String relationshipGoal;
    private String residencePlan;
    private String careerDirection;
    private String country;
    private String nationality;
    private String preferredEducation;
    private String familyLife;
    private List<String> dealBreakers;
    private String exercise;
    private List<String> personalityTraits;
    private List<String> interests;
    private boolean isVerified;
    private boolean isFeatured;

    public String getId()
    {
        return id;
    }

    public void setId(String id)
    {
        this.id = id;
    }

    public String getProfileType()
    {
        return profileType;
    }

    public void setProfileType(String profileType)
    {
        this.profileType = profileType;
    }

    public String getGender()
    {
        return gender;
    }

    public void setGender(String gender)
    {
        this.gender = gender;
    }

    public int getBirthYear()
    {
        return birthYear;
    }

    public void setBirthYear(int birthYear)
    {
        this.birthYear = birthYear;
    }

    public int getHeight()
    {
        return height;
    }

    public void setHeight(int height)
    {
        this.height = height;
    }

    public String getCityCode()
    {
        return cityCode;
    }

    public void setCityCode(String cityCode)
    {
        this.cityCode = cityCode;
    }

    public String getCountryCode()
    {
        return countryCode;
    }

    public void setCountryCode(String countryCode)
    {
        this.countryCode = countryCode;
    }

    public String getNationalityCode()
    {
        return nationalityCode;
    }

    public void setNationalityCode(String nationalityCode)
    {
        this.nationalityCode = nationalityCode;
    }

    public String getProfileStatus()
    {
        return profileStatus;
    }

    public void setProfileStatus(String profileStatus)
    {
        this.profileStatus = profileStatus;
    }

    public Date getLastActiveAt()
    {
        return lastActiveAt;
    }

    public void setLastActiveAt(Date lastActiveAt)
    {
        this.lastActiveAt = lastActiveAt;
    }

    public boolean isFamilyVisible()
    {
        return familyVisible;
    }

    public void setFamilyVisible(boolean familyVisible)
    {
        this.familyVisible = familyVisible;
    }

    public String getDegreeLevel()
    {
        return degreeLevel;
    }

    public void setDegreeLevel(String degreeLevel)
    {
        this.degreeLevel = degreeLevel;
    }

    public String getEducationCode()
    {
        return educationCode;
    }

    public void setEducationCode(String educationCode)
    {
        this.educationCode = educationCode;
    }

    public String getIndustryCode()
    {
        return industryCode;
    }

    public void setIndustryCode(String industryCode)
    {
        this.industryCode = industryCode;
    }

    public String getMaritalStatus()
    {
        return maritalStatus;
    }

    public void setMaritalStatus(String maritalStatus)
    {
        this.maritalStatus = maritalStatus;
    }

    public boolean isHasChildren()
    {
        return hasChildren;
    }

    public void setHasChildren(boolean hasChildren)
    {
        this.hasChildren = hasChildren;
    }

    public String getChildrenPlan()
    {
        return childrenPlan;
    }

    public void setChildrenPlan(String childrenPlan)
    {
        this.childrenPlan = childrenPlan;
    }

    public boolean isAcceptsLongDistance()
    {
        return acceptsLongDistance;
    }

    public void setAcceptsLongDistance(boolean acceptsLongDistance)
    {
        this.acceptsLongDistance = acceptsLongDistance;
    }

    public String getDatingIntentionCode()
    {
        return datingIntentionCode;
    }

    public void setDatingIntentionCode(String datingIntentionCode)
    {
        this.datingIntentionCode = datingIntentionCode;
    }

    public String getRelocation()
    {
        return relocation;
    }

    public void setRelocation(String relocation)
    {
        this.relocation = relocation;
    }

    public int getPreferredAgeMin()
    {
        return preferredAgeMin;
    }

    public void setPreferredAgeMin(int preferredAgeMin)
    {
        this.preferredAgeMin = preferredAgeMin;
    }

    public int getPreferredAgeMax()
    {
        return preferredAgeMax;
    }

    public void setPreferredAgeMax(int preferredAgeMax)
    {
        this.preferredAgeMax = preferredAgeMax;
    }

    public String getPreferredLocation()
    {
        return preferredLocation;
    }

    public void setPreferredLocation(String preferredLocation)
    {
        this.preferredLocation = preferredLocation;
    }

    public String getSmoking()
    {
        return smoking;
    }

    public void setSmoking(String smoking)
    {
        this.smoking = smoking;
    }

    public String getDrinking()
    {
        return drinking;
    }

    public void setDrinking(String drinking)
    {
        this.drinking = drinking;
    }

    public String getActivityLevel()
    {
        return activityLevel;
    }

    public void setActivityLevel(String activityLevel)
    {
        this.activityLevel = activityLevel;
    }

    public String getWeekendStyle()
    {
        return weekendStyle;
    }

    public void setWeekendStyle(String weekendStyle)
    {
        this.weekendStyle = weekendStyle;
    }

    public String getPets()
    {
        return pets;
    }

    public void setPets(String pets)
    {
        this.pets = pets;
    }

    public String getCommunicationStyle()
    {
        return communicationStyle;
    }

    public void setCommunicationStyle(String communicationStyle)
    {
        this.communicationStyle = communicationStyle;
    }

    public Date getArchivedAt()
    {
        return archivedAt;
    }

    public void setArchivedAt(Date archivedAt)
    {
        this.archivedAt = archivedAt;
    }

    public Date getCreatedAt()
    {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt)
    {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt()
    {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt)
    {
        this.updatedAt = updatedAt;
    }

    public Integer getPage()
    {
        return page;
    }

    public void setPage(Integer page)
    {
        this.page = page;
    }

    public Integer getAgeMin()
    {
        return ageMin;
    }

    public void setAgeMin(Integer ageMin)
    {
        this.ageMin = ageMin;
    }

    public Integer getAgeMax()
    {
        return ageMax;
    }

    public void setAgeMax(Integer ageMax)
    {
        this.ageMax = ageMax;
    }

    public Integer getHeightMin()
    {
        return heightMin;
    }

    public void setHeightMin(Integer heightMin)
    {
        this.heightMin = heightMin;
    }

    public Integer getHeightMax()
    {
        return heightMax;
    }

    public void setHeightMax(Integer heightMax)
    {
        this.heightMax = heightMax;
    }

    public String getLanguage()
    {
        return language;
    }

    public void setLanguage(String language)
    {
        this.language = language;
    }

    public String getSort()
    {
        return sort;
    }

    public void setSort(String sort)
    {
        this.sort = sort;
    }

    public String getFamilyMode()
    {
        return familyMode;
    }

    public void setFamilyMode(String familyMode)
    {
        this.familyMode = familyMode;
    }

    public String getLocale()
    {
        return locale;
    }

    public void setLocale(String locale)
    {
        this.locale = locale;
    }

    public String getViewerUserId()
    {
        return viewerUserId;
    }

    public void setViewerUserId(String viewerUserId)
    {
        this.viewerUserId = viewerUserId;
    }

    public Boolean getHasChildrenFilter()
    {
        return hasChildrenFilter;
    }

    public void setHasChildrenFilter(Boolean hasChildrenFilter)
    {
        this.hasChildrenFilter = hasChildrenFilter;
    }

    public Boolean getAcceptsLongDistanceFilter()
    {
        return acceptsLongDistanceFilter;
    }

    public void setAcceptsLongDistanceFilter(Boolean acceptsLongDistanceFilter)
    {
        this.acceptsLongDistanceFilter = acceptsLongDistanceFilter;
    }

    public int getPageSize()
    {
        return pageSize;
    }

    public void setPageSize(int pageSize)
    {
        this.pageSize = pageSize;
    }

    public int getOffset()
    {
        return offset;
    }

    public void setOffset(int offset)
    {
        this.offset = offset;
    }

    public String getVerified()
    {
        return verified;
    }

    public void setVerified(String verified)
    {
        this.verified = verified;
    }

    public int getCount()
    {
        return count;
    }

    public void setCount(int count)
    {
        this.count = count;
    }

    public List<CupidProfilePhoto> getPhotos()
    {
        return photos;
    }

    public void setPhotos(List<CupidProfilePhoto> photos)
    {
        this.photos = photos;
    }

    public int getAge()
    {
        return age;
    }

    public void setAge(int age)
    {
        this.age = age;
    }

    public List<String> getLanguages()
    {
        return languages;
    }

    public void setLanguages(List<String> languages)
    {
        this.languages = languages;
    }

    public String getDisplayName()
    {
        return displayName;
    }

    public void setDisplayName(String displayName)
    {
        this.displayName = displayName;
    }

    public String getAvatarUrl()
    {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl)
    {
        this.avatarUrl = avatarUrl;
    }

    public String getCity()
    {
        return city;
    }

    public void setCity(String city)
    {
        this.city = city;
    }

    public String getEducation()
    {
        return education;
    }

    public void setEducation(String education)
    {
        this.education = education;
    }

    public String getIndustry()
    {
        return industry;
    }

    public void setIndustry(String industry)
    {
        this.industry = industry;
    }

    public String getDatingIntentionLabel()
    {
        return datingIntentionLabel;
    }

    public void setDatingIntentionLabel(String datingIntentionLabel)
    {
        this.datingIntentionLabel = datingIntentionLabel;
    }

    public String getSummary()
    {
        return summary;
    }

    public void setSummary(String summary)
    {
        this.summary = summary;
    }

    public List<String> getTags()
    {
        return tags;
    }

    public void setTags(List<String> tags)
    {
        this.tags = tags;
    }

    public List<String> getRelationshipValues()
    {
        return relationshipValues;
    }

    public void setRelationshipValues(List<String> relationshipValues)
    {
        this.relationshipValues = relationshipValues;
    }

    public String getRelationshipGoal()
    {
        return relationshipGoal;
    }

    public void setRelationshipGoal(String relationshipGoal)
    {
        this.relationshipGoal = relationshipGoal;
    }

    public String getResidencePlan()
    {
        return residencePlan;
    }

    public void setResidencePlan(String residencePlan)
    {
        this.residencePlan = residencePlan;
    }

    public String getCareerDirection()
    {
        return careerDirection;
    }

    public void setCareerDirection(String careerDirection)
    {
        this.careerDirection = careerDirection;
    }

    public String getCountry()
    {
        return country;
    }

    public void setCountry(String country)
    {
        this.country = country;
    }

    public String getNationality()
    {
        return nationality;
    }

    public void setNationality(String nationality)
    {
        this.nationality = nationality;
    }

    public String getPreferredEducation()
    {
        return preferredEducation;
    }

    public void setPreferredEducation(String preferredEducation)
    {
        this.preferredEducation = preferredEducation;
    }

    public String getFamilyLife()
    {
        return familyLife;
    }

    public void setFamilyLife(String familyLife)
    {
        this.familyLife = familyLife;
    }

    public List<String> getDealBreakers()
    {
        return dealBreakers;
    }

    public void setDealBreakers(List<String> dealBreakers)
    {
        this.dealBreakers = dealBreakers;
    }

    public String getExercise()
    {
        return exercise;
    }

    public void setExercise(String exercise)
    {
        this.exercise = exercise;
    }

    public List<String> getPersonalityTraits()
    {
        return personalityTraits;
    }

    public void setPersonalityTraits(List<String> personalityTraits)
    {
        this.personalityTraits = personalityTraits;
    }

    public List<String> getInterests()
    {
        return interests;
    }

    public void setInterests(List<String> interests)
    {
        this.interests = interests;
    }

    public boolean getIsVerified()
    {
        return isVerified;
    }

    public void setIsVerified(boolean isVerified)
    {
        this.isVerified = isVerified;
    }

    public boolean getIsFeatured()
    {
        return isFeatured;
    }

    public void setIsFeatured(boolean isFeatured)
    {
        this.isFeatured = isFeatured;
    }
}
